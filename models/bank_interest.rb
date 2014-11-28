module Fortune
  class BankInterest
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "bank_interests"

    field :currency,   type: String
    field :rate,       type: Float
    field :maturity,   type: Integer   # by months

    class << self
      def load(currency, rate, maturity)
        interest = self.new(currency: currency,
                            rate:     rate,
                            maturity: maturity)
        if interest.save
          flogger.info "## Bank Interest saved with ID #{interest.attributes.to_s}"
        else
          flogger.info "## Skipping #{interest.attributes.to_s}..."
        end
      end
    end

    ###
    # Number of times the interest will mature annually
    ###
    def yearly_maturity
      12.0 / maturity
    end
  end
end
