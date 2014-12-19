module Fortune
  class App < Sinatra::Base
    register Sinatra::JstPages
    serve_jst '/jst.js'

    get '/' do
      haml :index
    end

    get '/login/?' do
      haml :login
    end

    get '/oauth2/:vendor/?' do
      oauth = _oauth_client(params)
      redirect oauth.authorize_url
    end

    get '/oauth2/callback/:vendor/?' do
      oauth   = _oauth_client(params)
      profile = oauth.get_profile(params[:code])
      Fortune::User.create(profile)
    end

    get '/currency-graph/?' do
      haml :'currency-graph'
    end

    error do
      status(500)
      haml :error
    end

    private
    def _oauth_client(params)
      vendor = params[:vendor]
      oauth = Fortune.const_get("OAuth2::#{vendor.camelize}").new(
        client_id: ENV["OAUTH2_#{vendor.upcase}_CLIENT_ID"],
        client_secret: ENV["OAUTH2_#{vendor.upcase}_CLIENT_SECRET"],
        callback_domain: ENV["OAUTH2_CALLBACK_DOMAIN"]
      )
    end
  end
end
