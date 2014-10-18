module Fortune
  class Investment
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::Validations
    extend  Fortune::Util

    store_in collection: "investments"

    field :capital,       type: Float   # money invested
    field :base_currency, type: String,  default: "USD"
    field :buy_currency,  type: String
    # the actual converted buy price from the bank (not market value)
    field :buy_price,     type: Float
    field :buy_date,      type: Date
    field :target_rate,   type: Float,   default: 0.03 # default is 3%
    # loss rate is intended for email notification when loss is more than 5%
    field :loss_rate,     type: Float,   default: 0.03 # default is -3%
    field :sold,          type: Boolean, default: false

    class << self
      def load_today(cap, currency, price)
        self.load(cap, currency, price, Date.today)
      end

      def load(cap, currency, price, date)
        investment = self.new(capital:       cap,
                            buy_currency:  currency,
                            buy_price:     price,
                            buy_date:      date)
        if investment.save
          flogger.info "## Investment saved with #{investment.attributes.to_s}"
        else
          flogger.info "## Skipping #{investment.attributes.to_s}"
        end
      end
    end

  end
end
