ENV["RACK_ENV"] ||= "development"

############### Loading gems ###############
require "rest-client"
require "bson"
require "moped"
require "mongoid"
require "highline/import"
require "awesome_print"
require "dotenv"
require "pry" if ENV["RACK_ENV"] == 'development'

Dotenv.load

unless File.directory?("logs")
  require 'fileutils'
  FileUtils.mkdir_p("logs")
end

Mongoid.load!("config/mongoid.yml") #Dotenv.load must be run first
Mongoid.logger = Logger.new("logs/mongo.log")
Moped.logger   = Logger.new("logs/mongo.log")

Moped::BSON = BSON  # Needed before initializing models directory

require_relative "../models/util"

############### Loading custom libraries ###############
lib = Dir["{lib,models}/**/*.rb"]

puts "## Loading #{lib}"

lib.each do |file|
  require_relative "../#{file}"
end
