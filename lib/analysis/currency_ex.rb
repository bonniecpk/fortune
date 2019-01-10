module Fortune::Analysis
  class CurrencyEx
    attr_reader :hourly_rate

    def initialize(investment)
      @investment = investment
      @buy_bank_rate  = Fortune::BankRate.where(base_currency: investment.base_currency,
                                                to_currency:   investment.buy_currency).first
      @sell_bank_rate = Fortune::BankRate.where(base_currency: investment.buy_currency,
                                                to_currency:   investment.base_currency).first
      @hourly_rate    = Fortune::HourlyRate.where(currency: investment.buy_currency,
                                                  datetime: {"$lt" => DateTime.now}).
                                            desc(:datetime).first

      raise MissingDataError.new("Missing Buy BankRate for #{@investment.attributes.to_s}") unless @buy_bank_rate
      raise MissingDataError.new("Missing Sell BankRate for #{@investment.attributes.to_s}") unless @sell_bank_rate
      raise MissingDataError.new("Missing Hourly Rate for #{@investment.attributes.to_s}") unless @hourly_rate
    end

    ###
    # Analysis methods
    ###
    
    def data
      %w(original_capital 
         converted_capital 
         current_capital 
         target_return
         target_sell_price 
         target_inverted_sell_price 
         actual_buy_price 
         market_buy_price 
         annual_maturity 
         matured_interest
         converted_interest
         current_interest
         current_sell_price 
         actual_sell_price 
         profit_delta
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
      @investment.loss_threshold
    end

    def profit_delta
      ((current_capital - original_capital) / original_capital).round(2)
    end

    ###
    # Investement info methods
    ###

    def original_capital
      @investment.capital
    end

    def target_return
      @investment.target_return
    end

    def current_capital
      converted_capital / actual_sell_price
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

    # The target sell price is more beneficial when the interest is matured
    def target_sell_price
      target_return / (converted_capital * (1 - @sell_bank_rate.fee))
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

    # The make-even price is more beneficial when the interest is matured
    def make_even_sell_price
      @investment.capital / (converted_capital * (1 - @sell_bank_rate.fee))
    end

    def make_even_inverted_sell_price
      1 / make_even_sell_price
    end

    ###
    # Interest related methods
    ###
    
    def matured_interest
      converted_interest / actual_sell_price
    end

    # Interest is zero if it's not mature
    def current_interest
      @investment.current_converted_interest / actual_sell_price
    end

    def annual_maturity
      @investment.annual_maturity
    end

    ###
    # Methods provide info based on the purchased currency
    ###
    
    # Converted capital may be added with interest when it is matured
    def converted_capital
      @investment.converted_capital + current_converted_interest
    end

    def converted_interest
      @investment.actual_converted_interest
    end

    # If interest hasn't matured yet, it returns 0
    def current_converted_interest
      @investment.current_converted_interest
    end

    ###
    # Notifications
    ###
    
    def notify?
      notification = @investment.notification

      # notification.percent is the stored value from the last delta, which 
      # is used to determine if a notification needs to be sent.
      return true unless notification
      return notification.percent != profit_delta
    end

    def notify_buyer
      subject = "#{@investment.buy_currency}: #{profit_delta}"

      Fortune::Mailer.send(subject: subject, content: html_body)
      flogger.info "Email sent"

      # This line will replace an existing notification in MongoDB if it ever exists
      @investment.notification = Fortune::Notification.new(percent: profit_delta)
    end

    private
    def html_body
      "#{data.collect { |k,v| "#{k} = #{v}" }.join("<br/>")}
       <br/>
       Current rate (as of #{@hourly_rate.datetime} = $#{@hourly_rate.price}"
    end
  end
end

