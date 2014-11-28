require_relative "../../spec_helper"

describe Fortune::Analysis::CurrencyEx do
  DEBUG = ENV["DEBUG"] || false

  # Save all the necessary info into database for analysis engine to process
  def sample_data(investment)
    {
      buy_bank_rate: create(:bank_rate, 
                            base_currency: investment.base_currency,
                            to_currency: investment.buy_currency),
      sell_bank_rate: create(:bank_rate, 
                             base_currency: investment.buy_currency,
                             to_currency: investment.base_currency),
      bank_interest: create(:bank_interest,
                            currency: investment.buy_currency),
      hourly_rate: create(:hourly_rate,
                          currency: investment.buy_currency,
                          price: investment.buy_price,
                          datetime: DateTime.now - 2.hour)
    }
  end

  before(:all) do
    @investment = build(:investment)
  end

  it "Missing bank rate" do
    expect { Fortune::Analysis::CurrencyEx.new(@investment) }.to \
      raise_error(Fortune::Analysis::MissingDataError)
  end

  context "#interest_mature?" do
    it "Matured" do
      investment = build(:investment, buy_date: Date.today - 2.years)
      sample     = sample_data(investment)
      analysis   = Fortune::Analysis::CurrencyEx.new(investment)

      expect(analysis.interest_mature?).to be(true)
    end

    it "Not matured" do
      investment = build(:investment, buy_date: Date.today + 1.day)
      sample     = sample_data(investment)
      analysis   = Fortune::Analysis::CurrencyEx.new(investment)

      expect(analysis.interest_mature?).to be(false)
    end
  end

  context "Default sample data" do
    before(:each) do
      @sample = sample_data(@investment)
    end

    context "Investment info" do
      before(:each) do
        @analysis   = Fortune::Analysis::CurrencyEx.new(@investment)
      end

      it "#original_capital" do 
        expect(@analysis.original_capital).to eq(@investment.capital)
      end

      it "#target_return" do
        expect(@analysis.target_return).to eq(@investment.target_return)
      end

      it "#current_capital" do
        expect(@analysis.current_capital).to eq(@analysis.converted_capital / 
                                                @analysis.actual_sell_price)
      end
    end

    context "Analysis methods" do
      before(:each) do
        @analysis   = Fortune::Analysis::CurrencyEx.new(@investment)
      end

      it "#profit_delta" do
        expect(@analysis.profit_delta).to \
          eq(((@analysis.current_capital - @analysis.original_capital) / 
              @analysis.original_capital).round(2))
      end
    end

    context "Buy/Sell methods" do
      before(:each) do
        @analysis   = Fortune::Analysis::CurrencyEx.new(@investment)
      end

      it "#make_even_sell_price" do
        expect(@analysis.make_even_sell_price).to \
          eq(@investment.capital / 
             (@analysis.converted_capital * (1 - @sample[:sell_bank_rate].fee)))
      end
    end

    context "#notify?" do
      it "Reach profit line" do
        # Save a profit hourly rate
        create(:hourly_rate,
               currency: @investment.buy_currency,
               price: @investment.buy_price * (1 - 5 * @investment.target_rate),
               datetime: DateTime.now - 1.hour)
        analysis    = Fortune::Analysis::CurrencyEx.new(@investment)

        ap analysis.data if DEBUG

        expect(analysis.notify?).to eq(true)
      end

      it "Reach loss threshold" do
        # Save a loss hourly rate. Make it lose so much and interest can't be cover
        create(:hourly_rate,
               currency: @investment.buy_currency,
               price: @investment.buy_price * 100000,
               datetime: DateTime.now - 1.hour)
        analysis    = Fortune::Analysis::CurrencyEx.new(@investment)

        ap analysis.data if DEBUG

        expect(analysis.notify?).to eq(true)
      end

      it "Notified and delta profit remains the same" do
        # Save a profit hourly rate
        create(:hourly_rate,
               currency: @investment.buy_currency,
               price: @investment.buy_price * (1 - @investment.target_rate),
               datetime: DateTime.now - 1.hour)

        analysis                 = Fortune::Analysis::CurrencyEx.new(@investment)
        @investment.notification = Fortune::Notification.new(percent: analysis.profit_delta)
        
        expect(analysis.notify?).to eq(false)
      end

      it "Notified and delta profit is changed" do
        @investment.notification = Fortune::Notification.new(percent: 0)

        # Save a profit hourly rate
        create(:hourly_rate,
               currency: @investment.buy_currency,
               price: @investment.buy_price * (1 - 5 * @investment.target_rate),
               datetime: DateTime.now - 1.hour)
        analysis    = Fortune::Analysis::CurrencyEx.new(@investment)

        ap analysis.data if DEBUG

        expect(analysis.notify?).to eq(true)
      end

      it "Notified loss and now make even" do
        @investment.notification = Fortune::Notification.new(percent: -0.03)
        analysis                 = Fortune::Analysis::CurrencyEx.new(@investment)

        ap analysis.data if DEBUG

        # Save a hourly rate that makes even
        create(:hourly_rate,
               currency: @investment.buy_currency,
               price: analysis.make_even_inverted_sell_price,
               datetime: DateTime.now - 1.hour)

        analysis2 = Fortune::Analysis::CurrencyEx.new(@investment)
        ap analysis2.data if DEBUG
        expect(analysis2.notify?).to eq(true)
      end
    end

    context "#notify_buyer" do
      it "New notification" do
        analysis    = Fortune::Analysis::CurrencyEx.new(@investment)

        analysis.notify_buyer

        expect(@investment.notification.class).to eq(Fortune::Notification)
      end

      it "Update notification" do
        @investment.notification = Fortune::Notification.new(percent: 0)
        analysis                 = Fortune::Analysis::CurrencyEx.new(@investment)

        analysis.notify_buyer

        expect(@investment.notification.percent).to eq(analysis.profit_delta)
      end
    end
  end
end
