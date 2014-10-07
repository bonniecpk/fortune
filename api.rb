module Fortune
  class Api < Sinatra::Base
    get '/daily_rates/:symbol' do
      Fortune::DailyRate.where(currency: params[:symbol].upcase).to_json
    end
  end
end
