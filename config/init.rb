require "rest-client"
require "dotenv"

Dotenv.load

# Loading custom libraries
lib = Dir["lib/**/*.rb"]

puts "Loading #{lib}"

lib.each do |file|
  require_relative "../#{file}"
end
