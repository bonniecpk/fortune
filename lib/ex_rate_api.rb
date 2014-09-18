module Fortune
  class ExRateApi
    BASE_URL = "http://openexchangerates.org/api/"
    API_ID   = ENV["EX_RATE_API_ID"]

    def initialize
    end

    def currencies
      _api("currencies")
    end

    def historial(date)

    end

    def daily
      _api("latest")
    end

    private
    def _api(api, params={})
      url  = "#{BASE_URL}#{api}.json?app_id=#{API_ID}"
      
      puts "Calling #{url}"
      
      resp = RestClient.get("#{url}")
      JSON.parse(resp.body)
    end
  end
end
