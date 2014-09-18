require_relative "config/init"

api = Fortune::ExRateApi.new

namespace :store do
  task :daily do
    puts api.daily
  end
end
