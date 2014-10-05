module Fortune
  class DailyRate
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::Validations
    extend  Fortune::Util

    store_in collection: "daily_rates"

    field :currency,    type: String
    field :price,       type: Float
    field :date,        type: Date

    validates_uniqueness_of :currency, scope: :date

    class << self
      def load_today(currency, price)
        self.load(currency, price, Date.today)
      end

      def load(currency, price, date)
        daily_rate = self.new(currency:  currency,
                              price:     price,
                              date:      date)
        if daily_rate.save
          puts "## Daily Rate saved with ID #{daily_rate.id}, date: #{date}, currency: #{currency}, price: #{price}"
        else
          puts "## Skipping #{currency} #{date}..."
        end
      end
    end

  end
end
