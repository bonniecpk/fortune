module Fortune
  class BankRate
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "bank_rates"

    field :base_currency, type: String, default: "USD"
    field :to_currency,   type: String
    field :fee,           type: Float,  default: 0.075

    class << self
      def load(base, to, fee)
        bank_rate = self.new(base_currency: base,
                             to_currency:   to,
                             fee:           fee)
        if bank_rate.save
          flogger.info "## Bank Rate saved with #{bank_rate.attributes.to_s}"
        else
          flogger.info "## Skipping #{bank_rate.attributes.to_s}"
        end
      end
    end

  end
end
