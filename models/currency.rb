module Fortune
  class Currency
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "currencies"

    field :name,       type: String
    field :symbol,     type: String
    field :enabled,    type: Boolean

    validates_uniqueness_of :symbol

    class << self
      def load(name, symbol)
        currency = self.new(symbol: symbol, name: name)
        if currency.save
          flogger.info "## Currency saved with ID #{currency.id}, symbol: #{symbol}, name: #{name}"
        else
          flogger.info "## Skipping #{name} (#{symbol})..."
        end
      end

      def set_enabled(symbol, enabled)
        self.where(symbol: symbol.upcase).
          find_and_modify({"$set" => { enabled: enabled }}, new: true)
      end
    end
  end
end
