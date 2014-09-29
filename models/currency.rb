class Currency
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "currencies"

  field :name,       type: String
  field :symbol,     type: String

  def self.load(name, symbol)
    if where(symbol: symbol).exists?
      puts "## Skipping #{name} (#{symbol})..."
      return
    end

    currency = self.new(symbol: symbol, name: name)
    if currency.save
      puts "## Currency saved with ID #{currency.id}, symbol: #{symbol}, name: #{name}"
    else
      puts "## Failed to save currency, symbol: #{symbol}, name: #{name}"
    end
  end
end

