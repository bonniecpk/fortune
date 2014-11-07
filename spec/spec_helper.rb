require 'rack/test'
require 'factory_girl'
require 'database_cleaner'

ENV["RACK_ENV"]    ||= "test"

require_relative '../config/init'

include Rack::Test::Methods

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order     = "random"

  # Show color for test run status
  config.color     = true

  # Showing each test in each line instead of using dot representation
  config.formatter = :documentation

  # FactoryGirl.lint builds each factory and subsequently calls #valid? 
  # on it (if #valid? is defined); if any calls to #valid? return false, 
  # FactoryGirl::InvalidFactoryError is raised with a list of the offending 
  # factories. Recommended usage of FactoryGirl.lint is to invoke this once 
  # before the test suite is run.
  config.before(:suite) do
    FactoryGirl.lint
  end

  # Allow factories to be loaded
  config.before(:all) do
    FactoryGirl.reload
  end

  # Erase all the data after each test run
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
