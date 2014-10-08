namespace :exec do
  task :abs do
    minmax   = ask("Max/Min? ").downcase
    currency = ask("Currency symbol: ")
    query    = Fortune::DailyRate.where(currency: currency.upcase)
    obj      = query.send("#{minmax}_obj", :price)

    flogger.info "#{minmax}: #{obj.date} $#{obj.price}"
  end

  task :currencies do
    Fortune::Currency.each do |c|
      flogger.info "#{c.name}: #{c.symbol}"
    end
  end
end
