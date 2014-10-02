module Fortune
  module Util
    %w(max min).each do |meth|
      define_method("#{meth}_obj") do |col|
        result = nil

        self.each do |obj|
          result = obj if result.nil? || (result.try(col) <=> obj.price) == (meth == "max" ? -1 : 1) 
        end

        result
      end
    end
  end
end
