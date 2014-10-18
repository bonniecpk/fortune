module Fortune
  module Util
    class ParseError < StandardError; end

    %w(max min).each do |meth|
      define_method("#{meth}_obj") do |col|
        result = nil

        self.each do |obj|
          result = obj if result.nil? || (result.try(col) <=> obj.price) == (meth == "max" ? -1 : 1) 
        end

        result
      end
    end

    # Rounding the time to hourly. 0-29 will be rounded down,
    # and 30-59 will be rounded up
    #
    # For example:
    #   13:23 will become 13:00
    #   13:34 will become 14:00
    #
    def round_time(datetime)
      begin
        offset = datetime.to_time.min < 30 ? 0 : 1.hour
        datetime.beginning_of_hour + offset
      rescue Exception => e
        raise ParseError.new("#{datetime.class} can't be rounded")
      end
    end
  end
end
