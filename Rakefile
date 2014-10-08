require_relative "config/init"

def api
  Fortune::ExRateApi.new
end

Dir["lib/tasks/**/*.rake"].each do |file|
  load file
end


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
