ENV["RACK_ENV"] ||= "development"

############### Loading gems ###############
require "sinatra/base"
require "sinatra/jstpages"
require "haml"
require "sass"
require "sprockets"
require "rest-client"
require "bson"
require "moped"
require "mongoid"
require "highline/import"
require "awesome_print"
require "dotenv"
require "fileutils"
require "pony"
require "oauth2"

if ENV["RACK_ENV"] == 'development' || ENV['RACK_ENV'] == 'test'
  require "pry"
  require "shoulda/matchers"
end

Dotenv.load

FileUtils.mkdir_p("log") unless File.directory?("log")

Mongoid.load!("config/mongoid.yml") #Dotenv.load must be run first
Mongoid.logger = Logger.new("log/mongo.log")
Moped.logger   = Logger.new("log/mongo.log")

Moped::BSON = BSON  # Needed before initializing models directory

require_relative "../models/util"

############### Loading custom libraries ###############
lib = Dir["{lib,models}/**/*.rb"]

lib.each do |file|
  require_relative "../#{file}"
end

############### Initializing the app ###################
def flogger
  Fortune::Logger.get
end

flogger.info "## RACK_ENV=#{ENV["RACK_ENV"]}"
flogger.info "## Loading #{lib}"

require_relative "../app"
require_relative "../api"
