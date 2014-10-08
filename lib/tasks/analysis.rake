namespace :analysis do
  task :top_currencies do
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

      analysis[:profit] = (analysis[:max].price - analysis[:today].price) / analysis[:today].price * 100
      analysis[:loss]   = (analysis[:min].price - analysis[:today].price) / analysis[:today].price * 100

      result << analysis
    end

    print_result(result)
    
    top_5 = result.sort_by { |a| a[:profit] }.reverse[0..5]

    puts "############################# TOP 5 ##################################"
    print_result(top_5)
  end

  def print_result(result)
    result.each do |values|
      puts """
        #{values[:currency].symbol} - #{values[:currency].name}
          MAX     = #{values[:max].price} (#{values[:max].date})
          MIN     = #{values[:min].price} (#{values[:min].date})
          TODAY   = #{values[:today].try(:price)}
          PROFIT  = #{values[:profit].round(2)}%
          LOSS    = #{values[:loss].round(2)}%
      """
    end
  end
end
