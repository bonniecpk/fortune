namespace :analysis do
  task :notify do
    investments = Fortune::Investment.where(sold: false)

    investments.each do |investment|
      buy_bank_rate  = Fortune::BankRate.where(base_currency: investment.base_currency,
                                               to_currency:   investment.buy_currency).first
      sell_bank_rate = Fortune::BankRate.where(base_currency: investment.buy_currency,
                                               to_currency:   investment.base_currency).first
      bank_interest  = Fortune::BankInterest.where(currency:  investment.buy_currency).first

      unless buy_bank_rate
        flogger.error "Missing Buy BankRate for #{investment.attributes.to_s}"
        next
      end

      unless sell_bank_rate
        flogger.error "Missing Sell BankRate for #{investment.attributes.to_s}"
        next
      end

      target_return     = investment.capital * (1 + investment.target_rate)
      market_buy_price  = investment.buy_price / (1 - buy_bank_rate.fee)
      converted_capital = investment.capital * investment.buy_price
      yearly_maturity   = 12 / bank_interest.maturity
      converted_interest = bank_interest ? converted_capital * (bank_interest.rate / yearly_maturity) : 0
      converted_total_return = converted_capital + converted_interest
      target_sell_price = target_return / (converted_total_return * (1 - sell_bank_rate.fee))
      hourly_rate       = Fortune::HourlyRate.where(currency: investment.buy_currency, 
                                                    datetime: {"$lt" => DateTime.now}).first
      actual_sell_price = hourly_rate.price * (1 + sell_bank_rate.fee)
      interest          = converted_interest / actual_sell_price
      current_capital   = converted_capital / actual_sell_price
      loss_threshold    = investment.capital * (1 - investment.loss_rate)
      i_current_capital = (converted_capital + interest) / actual_sell_price
      i_loss_threshold  = investment.capital * (1 - investment.loss_rate)

      calculations = {
        target_return:          target_return,
        market_buy_price:       market_buy_price,
        converted_capital:      converted_capital,
        yearly_maturity:        yearly_maturity,
        interest:               interest,
        converted_interest:     converted_interest,
        converted_total_return: converted_total_return,
        target_sell_price:      target_sell_price,
        inverted_sell_price:    1 / target_sell_price,
        current_capital:        current_capital,
        loss_threshold:         loss_threshold,
        i_current_capital:      i_current_capital,
        i_loss_threshold:       i_loss_threshold
      }

      ap calculations
      flogger.info calculations
      flogger.info "Current rate (as of #{hourly_rate.datetime}) = $#{hourly_rate.price}"

      if hourly_rate.price <= calculations[:inverted_sell_price]
        subject = "Time to sell #{investment.buy_currency}!"
      elsif current_capital < loss_threshold
        subject   = "WARNING: Investment dropped #{investment.loss_rate}"
      end

      if subject
        flogger.info "Email sent"

        Pony.mail({
          from:      'exchange@pchui.me',
          to:        'poki.developer@gmail.com',
          subject:   subject,
          html_body: html_body(calculations, hourly_rate),
          via:       :smtp,
          via_options: {
            port:    ENV["SMTP_PORT"] ? ENV["SMTP_PORT"] : 25,
            enable_starttls_auto: true
          }
        })
      end
    end
  end

  task :top_10 do
    start = ask("Start Date (YYYY-MM-DD)? ")
    query = Fortune::DailyRate.where(:date.gte => Date.parse(start)).group_by(&:currency)

    result = []
    query.each do |symbol, rates|
      currency   = Fortune::Currency.where(symbol: symbol).first
      today_rate = Fortune::DailyRate.where(date:     Date.today,
                                            currency: symbol).first

      flogger.debug "Running #{symbol}...."

      if currency.nil?
        flogger.debug "Skipping #{symbol} (not exist in currency table)..."
        next
      # skipping disabled currencies
      elsif currency.has_attribute?(:enabled) && !currency.enabled
        flogger.debug "Skipping #{symbol} (Disabled)..."
        next
      # Currency may exist in the past, but not today
      elsif today_rate.nil?
        flogger.debug "Skipping #{symbol} (Not exist today)..."
        next
      end

      analysis = {
        currency: currency,
        max:      rates.max_by(&:price),
        min:      rates.min_by(&:price),
        today:    today_rate
      }

      analysis[:profit] = (analysis[:max].price - analysis[:today].price) / 
        analysis[:today].price * 100
      analysis[:loss]   = (analysis[:min].price - analysis[:today].price) / 
        analysis[:today].price * 100

      result << analysis
    end

    top_10 = result.sort_by { |a| a[:profit] }.reverse[0..10]

    reporter.info("################# TOP 10 (Start Date: #{start}) #####################")
    print_result(top_10)
  end

  def reporter
    FileUtils.mkdir_p(ENV["ANALYSIS_DIR"]) unless File.directory?(ENV["ANALYSIS_DIR"])
    Fortune::PlainLogger.new("#{ENV["ANALYSIS_DIR"]}/analysis.txt")
  end

  def print_result(result)
    result.each do |values|
      output = """
        #{values[:currency].symbol} - #{values[:currency].name}
          MAX     = #{values[:max].price} (#{values[:max].date})
          MIN     = #{values[:min].price} (#{values[:min].date})
          TODAY   = #{values[:today].try(:price)}
          PROFIT  = #{values[:profit].round(2)}%
          LOSS    = #{values[:loss].round(2)}%\n"""

      reporter.info(output)
    end
  end

  def html_body(calculations, hourly_rate)
    "#{calculations.collect { |k,v| "#{k} = #{v}" }.join("<br/>")}
    <br/>
    Current rate (as of #{hourly_rate.datetime} = $#{hourly_rate.price}"
  end
end
