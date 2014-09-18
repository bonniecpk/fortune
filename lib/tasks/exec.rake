namespace :exec do
  task :abs do
    max      = ask("Max/Min? ") =~ /[Mm]ax/
    currency = ask("Currency symbol: ")
    query    = DailyRate.where(currency: currency)

    if max
      puts "Max: $#{query.max(:price)}"
    else
      puts "Min: $#{query.min(:price)}"
    end
  end

  task :currencies do
    Currency.each do |c|
      puts "#{c.name}: #{c.symbol}"
    end
  end
end
