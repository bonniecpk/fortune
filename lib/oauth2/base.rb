module Fortune::OAuth2
  class Base
    def initialize(**args)
      @client_id       = args[:client_id]
      @client_secret   = args[:client_secret]
      @redirect_uri    = "#{args[:callback_domain]}/oauth2/callback/#{self.class.to_s.demodulize.downcase}"
    end

    def authorize_url
      raise NotImplementedError
    end

    def login(code)
      raise NotImplementedError
    end
  end
end
