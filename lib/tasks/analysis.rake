namespace :analysis do
  task :profit_notification do
    purchases = Fortune::Purchase.where(sold: false)

    purchases.each do |purchase|
      buy_bank_rate  = Fortune::BankRate.where(base_currency: purchase.base_currency,
                                               to_currency:   purchase.buy_currency).first
      sell_bank_rate = Fortune::BankRate.where(base_currency: purchase.buy_currency,
                                               to_currency:   purchase.base_currency).first
      bank_interest  = Fortune::BankInterest.where(currency:  purchase.buy_currency).first

      unless buy_bank_rate
        flogger.error "Missing Buy BankRate for #{purchase.attributes.to_s}"
        next
      end

      unless sell_bank_rate
        flogger.error "Missing Sell BankRate for #{purchase.attributes.to_s}"
        next
      end

      target_return     = purchase.capital * (1 + purchase.target_rate / 100)
      market_buy_price  = purchase.buy_price / (1 - buy_bank_rate.fee / 100)
      converted_capital = purchase.capital * purchase.buy_price
      yearly_maturity   = 12 / bank_interest.maturity
      interest          = bank_interest ? converted_capital * (bank_interest.rate / 100 / yearly_maturity) : 0
      converted_total_return = converted_capital + interest
      target_sell_price = target_return / (converted_total_return * (1 - sell_bank_rate.fee / 100))

      calculations = {
        target_return:          target_return,
        market_buy_price:       market_buy_price,
        converted_capital:      converted_capital,
        yearly_maturity:        yearly_maturity,
        interest:               interest,
        converted_total_return: converted_total_return,
        target_sell_price:      target_sell_price,
        inverted_sell_price:    1 / target_sell_price
      }

      ap calculations

      today_rate = Fortune::DailyRate.where(currency: purchase.buy_currency, date: Date.today).first
      if today_rate.price <= calculations[:inverted_sell_price]
        Pony.mail({
          from:      'exchange@pchui.me',
          to:        'poki.developer@gmail.com',
          subject:   "Time to sell #{purchase.buy_currency}!",
          html_body: "#{calculations} and today's rate = #{today_rate.price}",
          via_options: {
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
end
