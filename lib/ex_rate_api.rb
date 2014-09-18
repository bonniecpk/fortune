module Fortune
  class ExRateApi
    def initialize
      BASE_URL = "http://openexchangerates.org/api/"
      API_ID   = ENV["EX_RATE_API_ID"]
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
      RestClient.get("#{BASE_URL}#{api}.json", params.merge({app_id: API_ID}))
      JSON.parse(resp.body)
    end
  end
end
