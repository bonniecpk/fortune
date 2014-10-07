require './config/init'

map('/assets') do
  env = Sprockets::Environment.new
  env.append_path 'assets/js'
  env.append_path 'assets/css'

  run env
end

map('/')       { run Fortune::App }
map('/api/v1') { run Fortune::Api }
