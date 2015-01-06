module Fortune
  class Interest
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :investment

    field :rate,            type: Float
    field :amount,          type: Float,   default: 0
    field :mature_length,   type: Integer   # by months
    field :start,           type: Date

    class << self
      def load(investment_id, rate, mature_length, start)
        investment = Fortune::Investment.where(id: investment_id)
        interest   = self.new(rate: rate,
                              mature_length: mature_length,
                              start: Date.parse(start))
        investment.interests << interest

        flogger.info "## Interest saved in investment ID #{investment_id}. Interest: #{interest.attributes.to_s}"
      end
    end

    ###
    # Number of times the interest will mature annually
    ###
    def annual_maturity
      12.0 / mature_length
    end

    def mature?
      start + mature_length.months <= Date.today
    end

    # amount can override the actual interest calculation if it exists
    def actual_converted_amount
      amount == 0 ? investment.converted_capital * (1 + rate / annual_maturity) : amount
    end

    # the interest will be zero if it's immature. Otherwise, the actual amount is returned
    def current_converted_amount
      mature? ? actual_amount : 0
    end
  end
end
