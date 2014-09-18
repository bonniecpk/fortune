class Currency
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "currencies"

  field :name,       type: String
  field :symbol,     type: String
end

