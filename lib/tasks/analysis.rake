namespace :analysis do

  def reporter
    FileUtils.mkdir_p(ENV["ANALYSIS_DIR"]) unless File.directory?(ENV["ANALYSIS_DIR"])
    Fortune::PlainLogger.new("#{ENV["ANALYSIS_DIR"]}/analysis.txt")
  end

  task :top_5 do
    start = ask("Start Date (YYYY-MM-DD)? ")
    query = Fortune::DailyRate.where(:date.gte => Date.parse(start)).group_by(&:currency)

    result = []
    query.each do |currency, rates|
      analysis = {
        currency: Fortune::Currency.where(symbol: currency).first,
        max:      rates.max_by(&:price),
        min:      rates.min_by(&:price),
        today:    Fortune::DailyRate.where(:date => Date.today, :currency => currency).first
      }

      analysis[:profit] = (analysis[:max].price - analysis[:today].price) / 
        analysis[:today].price * 100
      analysis[:loss]   = (analysis[:min].price - analysis[:today].price) / 
        analysis[:today].price * 100

      result << analysis
    end

    top_5 = result.sort_by { |a| a[:profit] }.reverse[0..5]

    reporter.info("################# TOP 5 (Start Date: #{start}) #####################")
    print_result(top_5)
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
