source 'http://rubygems.org'

gem 'sinatra'
gem 'haml'
gem 'sass'
gem 'rest-client'
gem 'dotenv'
gem 'mongoid'
gem 'highline'
gem 'awesome_print'
gem 'sprockets'
gem 'unicorn'
gem 'pony'
gem 'coffee-script'
gem 'oauth2'

# A bundle bug: Need execjs and therubyracer for the deployed server to work
gem 'execjs'
gem 'therubyracer'

# Javascript Related Gems
gem 'sinatra-backbone'

group :development, :test do
  gem 'rake'
end

group :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'shotgun'
  gem 'mailcatcher'
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano3-unicorn', :require => false
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'factory_girl'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'email_spec'
end
