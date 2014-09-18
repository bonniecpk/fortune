require_relative "config/init"

api = Fortune::ExRateApi.new

namespace :db_store do
  task :latest do
    puts api.latest
  end
end
