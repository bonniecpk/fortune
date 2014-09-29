class DailyRate
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "daily_rates"

  field :currency,    type: String
  field :price,       type: String
  field :date,        type: Date

  def self.exists_today?(currency)
    self.exists?(currency, Date.today)
  end

  def self.exists?(currency, date)
    where(currency: currency, date: date..date+1).exists?
  end

  def self.load_today(currency, price)
    self.load(currency, price, Date.today)
  end

  def self.load(currency, price, date)
    if exists?(currency, date)
      puts "## Skipping #{currency} #{date}..."
      return
    end

    daily_rate = self.new(currency:  currency,
                          price:     price,
                          date:      date)
    if daily_rate.save
      puts "## Daily Rate saved with ID #{daily_rate.id}, currency: #{currency}, price: #{price}"
    else
      puts "## Failed to save daily rate, currency: #{currency}, price: #{price}"
    end
  end
end

