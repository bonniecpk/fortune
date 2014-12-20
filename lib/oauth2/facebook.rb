module Fortune::OAuth2
  class Facebook < Base
    def authorize_url
      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site:          "https://www.facebook.com",
        authorize_url: "/dialog/oauth"
      )

      client.auth_code.authorize_url(
        redirect_uri: @redirect_uri,
        scope: "email public_profile"
      )
    end

    def get_profile(code)
      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site:          "https://graph.facebook.com",
        token_url:     "/v2.2/oauth/access_token"
      )
      
      # parse option is needed because Facebook API returns text/plain instead
      # of application/x-www-form-urlencoded in the response header
      token = client.auth_code.get_token(code, redirect_uri: @redirect_uri, parse: :query)

      json = RestClient.json_request(
        :get, 
        "https://graph.facebook.com/v2.2/me",
        headers: {:"Authorization" => "Bearer #{token.token}"}
      )

      {
        given_name: json[:first_name],
        surname:    json[:last_name],
        email:      json[:email],
        locale:     json[:locale]
      }
    end
  end
end
