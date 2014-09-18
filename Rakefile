require_relative "config/init"

api = Fortune::ExRateApi.new

namespace :load do
  task :latest do
    rates = api.latest["rates"]
    rates.each do |currency, price|
      daily_rate = DailyRate.new(currency:  currency,
                                 price:     price)
      if daily_rate.save
        puts "## Daily Rate saved with ID #{daily_rate.id}, currency: #{currency}, price: #{price}"
      else
        puts "## Failed to save daily rate, currency: #{currency}, price: #{price}"
      end
    end
  end

  task :currencies do
    currencies = api.currencies
    currencies.each do |symbol, name|
      currency = Currency.new(symbol: symbol, 
                   name:   name)
      if currency.save
        puts "## Currency saved with ID #{currency.id}, symbol: #{symbol}, name: #{name}"
      else
        puts "## Failed to save currency, symbol: #{symbol}, name: #{name}"
      end
    end
  end
end

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
