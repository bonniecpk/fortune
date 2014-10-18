module Fortune
  class HourlyRate
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::Validations
    extend  Fortune::Util

    store_in collection: "hourly_rates"

    field :currency,    type: String
    field :price,       type: Float
    field :datetime,    type: DateTime, default: round_time(DateTime.now)

    validates_uniqueness_of :currency, scope: :datetime

    class << self
      def load(currency, price, datetime = nil)
        hourly_rate          = self.new(currency:  currency,
                                        price:      price)
        hourly_rate.datetime = round_time(datetime) if datetime

        if hourly_rate.save
          flogger.info "## Hourly Rate saved with ID #{hourly_rate.id}, datetime: #{datetime}, currency: #{currency}, price: #{price}"
        else
          flogger.info "## Skipping #{currency} #{datetime}..."
        end
      end
    end

  end
end
