namespace :analysis do
  task :notify do
    investments = Fortune::Investment.where(sold: false)

    investments.each do |investment|
      begin
        engine       = Fortune::Analysis::CurrencyEx.new(investment)
        hourly_rate  = engine.hourly_rate
        data         = engine.data

        ap data
        flogger.info data
        flogger.info "Current rate (as of #{hourly_rate.datetime}) = $#{hourly_rate.price}"

        engine.notify_buyer if engine.notify?
      rescue Fortune::Analysis::MissingDataError => md_error
        flogger.error md_error.message
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
