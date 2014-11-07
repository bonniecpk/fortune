module Fortune::Analysis
  class CurrencyEx
    attr_reader :hourly_rate

    def initialize(investment)
      @investment = investment
      @buy_bank_rate  = Fortune::BankRate.where(base_currency: investment.base_currency,
                                                to_currency:   investment.buy_currency).first
      @sell_bank_rate = Fortune::BankRate.where(base_currency: investment.buy_currency,
                                                to_currency:   investment.base_currency).first
      @bank_interest  = Fortune::BankInterest.where(currency:  investment.buy_currency).first
      @hourly_rate    = Fortune::HourlyRate.where(currency: investment.buy_currency,
                                                  datetime: {"$lt" => DateTime.now}).
                                            desc(:datetime).first

      raise "Missing Buy BankRate for #{@investment.attributes.to_s}"  unless @buy_bank_rate
      raise "Missing Sell BankRate for #{@investment.attributes.to_s}" unless @sell_bank_rate
    end

    ###
    # Analysis methods
    ###
    
    def data
      %w(original_capital 
         converted_capital 
         target_return
         current_capital 
         target_sell_price 
         target_inverted_sell_price 
         actual_buy_price 
         market_buy_price 
         yearly_maturity 
         interest
         converted_interest 
         current_sell_price 
         actual_sell_price 
         current_capital
         current_capital_with_interest 
         loss_threshold).inject({}) do |hash, method|
        hash[method.to_sym] = send(method)
        hash
      end
    end

    def sell?
      @hourly_rate.price <= target_inverted_sell_price
    end

    def loss_beyond_threshold?
      current_capital < loss_threshold
    end

    def loss_threshold
      @investment.capital * (1 - @investment.loss_rate)
    end

    ###
    # Investement info methods
    ###

    def original_capital
      @investment.capital
    end

    def target_return
      @investment.capital * (1 + @investment.target_rate)
    end

    def current_capital
      converted_capital / actual_sell_price
    end

    def current_capital_with_interest
      (converted_capital + converted_interest) / actual_sell_price
    end

    ###
    # Buy/Sell price methods
    ###

    def market_buy_price
      @investment.buy_price / (1 - @buy_bank_rate.fee)
    end

    def actual_buy_price
      @investment.buy_price
    end

    def target_sell_price
      target_return / (converted_capital_with_interest * (1 - @sell_bank_rate.fee))
    end

    def actual_sell_price
      @hourly_rate.price * (1 + @sell_bank_rate.fee)
    end

    def current_sell_price
      @hourly_rate.price
    end

    def target_inverted_sell_price
      1 / target_sell_price
    end

    ###
    # Interest related methods
    ###
    
    def interest
      converted_interest / actual_sell_price
    end

    def yearly_maturity
      12 / @bank_interest.maturity
    end

    ###
    # Methods provide info based on the purchased currency
    ###
    
    def converted_capital
      @investment.capital * @investment.buy_price
    end

    def converted_interest
      @bank_interest ? converted_capital * (@bank_interest.rate / yearly_maturity) : 0
    end

    def converted_capital_with_interest
      converted_capital + converted_interest
    end
  end
end

