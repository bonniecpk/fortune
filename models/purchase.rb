module Fortune
  class Purchase
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::Validations
    extend  Fortune::Util

    store_in collection: "purchases"

    field :capital,       type: Float   # money invested
    field :base_currency, type: String,  default: "USD"
    field :buy_currency,  type: String
    field :buy_price,     type: Float
    field :buy_date,      type: Date
    field :target_rate,   type: Float,   default: "3" # default is 3%
    field :sold,          type: Boolean, default: false

    class << self
      def load_today(cap, currency, price)
        self.load(cap, currency, price, Date.today)
      end

      def load(cap, currency, price, date)
        purchase = self.new(capital:       cap,
                            buy_currency:  currency,
                            buy_price:     price,
                            buy_date:      date)
        if purchase.save
          flogger.info "## Purchase saved with #{purchase.attributes.to_s}"
        else
          flogger.info "## Skipping #{purchase.attributes.to_s}"
        end
      end
    end

  end
end
