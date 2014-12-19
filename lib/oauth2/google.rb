module Fortune::OAuth2
  class Google < Base
    def authorize_url
      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site:          "https://accounts.google.com",
        authorize_url: "/o/oauth2/auth"
      )

      client.auth_code.authorize_url(
        redirect_uri: @redirect_uri,
        scope: "email profile"
      )
    end

    def get_profile(code)
      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site:          "https://www.googleapis.com",
        token_url:     "/oauth2/v3/token"
      )
      token = client.auth_code.get_token(code, redirect_uri: @redirect_uri)

      json = RestClient.json_request(
        :get, 
        "https://www.googleapis.com/plus/v1/people/me",
        headers: {:"Authorization" => "#{token.params["token_type"]} #{token.token}"}
      )

      {
        firstname: json[:name][:givenName],
        lastname:  json[:name][:familyName],
        email:     json[:emails].first[:value],
        avatar:    json[:image][:url],
        lang:      json[:language]
      }
    end
  end
end
