module Fortune
  class PlainLogger < Logger
    def initialize(filepath)
      super(filepath)

      self.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end

    %w(debug info error fatal warn).each do |func|
      define_method(func) do |msg|
        super(msg)
        puts "#{msg}" unless ENV["RACK_ENV"] == 'test'
      end
    end
  end

  class ConsoleLogger < PlainLogger
    def initialize(filepath)
      super(filepath)

      self.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime} --- #{msg}\n"
      end
    end
  end

  class Logger
    def self.get
      FileUtils.mkdir_p("log") unless File.directory?("log")

      case ENV["ENVIRONMENT"]
      when "web" 
        ::Logger.new("log/web.log")
      when "plain"
        PlainLogger.new("log/plain.log")
      else
        ConsoleLogger.new("log/console.log")
      end
    end
  end
end
