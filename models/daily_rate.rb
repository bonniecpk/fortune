class DailyRate
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "daily_rates"

  field :currency,    type: String
  field :price,       type: String
  field :date,        type: Date
end

