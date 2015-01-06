module Fortune
  class Interest
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :investment

    field :rate,            type: Float
    field :mature_length,   type: Integer   # by months
    field :start,           type: Date

    class << self
      def load(investment_id, rate, mature_length, start)
        investment = Fortune::Investment.where(id: investment_id)
        investment.interests << self.new(rate: rate, 
                                         mature_length: mature_length,
                                         start: Date.parse(start))

        flogger.info "## Bank Interest saved with ID #{interest.attributes.to_s}"
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
  end
end
