namespace :load do
  task :latest do
    rates = @@api.latest["rates"]
    rates.each { |currency, price| DailyRate.load_today(currency, price) }
  end

  task :currencies do
    currencies = @@api.currencies
    currencies.each { |symbol, name| Currency.load(name, symbol) }
  end

  task :history do
    start_date = Date.strptime(ask("Start? (YYYY-mm-dd)"), "%Y-%m-%d")
    num_days   = ask("# of days? ").to_i
    dates      = start_date..(start_date + (num_days-1).days)

    dates.each do |date|
      rates = @@api.historical(date)["rates"]
      rates.each { |currency, price| DailyRate.load(currency, price, date) }
    end
  end
end
