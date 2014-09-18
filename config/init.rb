############### Loading gems ###############
require "rest-client"
require "bson"
require "moped"
require "mongoid"
require "highline/import"
require "awesome_print"
require "dotenv"

ENV["RACK_ENV"] ||= "development"

Dotenv.load

Mongoid.load!("config/mongoid.yml") #Dotenv.load must be run first
Mongoid.logger = Logger.new($stdout)
Moped.logger   = Logger.new($stdout)

Moped::BSON = BSON  # Needed before initializing models directory

############### Loading custom libraries ###############
lib = Dir["{lib,models}/**/*.rb"]

puts "## Loading #{lib}"

lib.each do |file|
  require_relative "../#{file}"
end
