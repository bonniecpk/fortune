module Fortune
  class Currency
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "currencies"

    field :name,       type: String
    field :symbol,     type: String

    validates_uniqueness_of :symbol

    def self.load(name, symbol)
      currency = self.new(symbol: symbol, name: name)
      if currency.save
        puts "## Currency saved with ID #{currency.id}, symbol: #{symbol}, name: #{name}"
      else
        puts "## Skipping #{name} (#{symbol})..."
      end
    end
  end
end
