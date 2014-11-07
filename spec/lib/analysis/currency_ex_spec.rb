require_relative "../../spec_helper"

describe Fortune::Analysis::CurrencyEx do
  before(:all) do
    @investment = create(:investment)
  end

  it "Missing bank rate" do
    expect { Fortune::Analysis::CurrencyEx.new(@investment) }.to raise_error(Fortune::Analysis::MissingDataError)
  end

  context "Investment info" do
    before(:each) do
      @buy_bank_rate = create(:bank_rate, 
                              base_currency: @investment.base_currency,
                              to_currency: @investment.buy_currency)
      @sell_bank_rate = create(:bank_rate, 
                               base_currency: @investment.buy_currency,
                               to_currency: @investment.base_currency)
      @bank_interest = create(:bank_interest,
                              currency: @investment.buy_currency)
      @hourly_rate   = create(:hourly_rate,
                              currency: @investment.buy_currency,
                              price: @investment.buy_price)
      @analysis      = Fortune::Analysis::CurrencyEx.new(@investment)
    end

    it "#original_capital" do 
      expect(@analysis.original_capital).to eq(@investment.capital)
    end
  end
end
