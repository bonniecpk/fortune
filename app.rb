module Fortune
  class App < Sinatra::Base
    register Sinatra::JstPages
    serve_jst '/jst.js'

    get '/' do
      'This is Fortune home page'
    end

    get '/currency-graph' do
      haml :'currency-graph'
    end

    ##-------------------##
    # Javascript Examples #
    ##-------------------##
    get '/drag-rect' do
      erb :'drag-rect'
    end

    get '/mouseout' do
      erb :mouseout
    end

    get '/scroll' do
      erb :scroll
    end
  end
end
