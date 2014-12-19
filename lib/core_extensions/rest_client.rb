module RestClient
  def self.json_request(method, url, **args)
    args.symbolize_keys!

    params  = args[:params]
    headers = (args[:headers] || {}).merge!(accept: :json)

    response = Request.execute(method: method, url: url, headers: headers, payload: params)

    unless response.nil?
      JSON.parse(response.to_s, symbolize_names: true)
    else
      false
    end
  end
end
