require_relative "config/init"

api = Fortune::ExRateApi.new

namespace :db_store do
  task :latest do
    rates = api.latest["rates"]
    rates.each do |currency, price|
      daily_rate = DailyRate.new(currency:  currency,
                                 price:     price)
      #daily_rate.id = Moped::BSON::ObjectId.new
      if daily_rate.save
        puts "Daily Rate saved with ID #{daily_rate.id}, currency: #{currency}, price: #{price}"
      else
        puts "Failed to save daily rate"
      end
    end
  end
end
