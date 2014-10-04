ENV["RACK_ENV"] ||= "development"

puts "## RACK_ENV=#{ENV["RACK_ENV"]}"

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
require "pry" if ENV["RACK_ENV"] == 'development' || ENV['RACK_ENV'] == 'test'

Dotenv.load

unless File.directory?("log")
  require 'fileutils'
  FileUtils.mkdir_p("log")
end

Mongoid.load!("config/mongoid.yml") #Dotenv.load must be run first
Mongoid.logger = Logger.new("log/mongo.log")
Moped.logger   = Logger.new("log/mongo.log")

Moped::BSON = BSON  # Needed before initializing models directory

require_relative "../models/util"

############### Loading custom libraries ###############
lib = Dir["{lib,models}/**/*.rb"]

puts "## Loading #{lib}"

lib.each do |file|
  require_relative "../#{file}"
end

require_relative "../app"
require_relative "../api"
