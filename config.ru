# ENVIRONMENT controls logging
# Values include [web | console]
ENV["ENVIRONMENT"] = "web"

require './config/init'

map('/assets') do
  env = Sprockets::Environment.new
  env.append_path 'assets/js'
  env.append_path 'assets/css'

  env.context_class.class_eval do
    def font_path(path, options = {})
      "/assets/fonts/#{path}"
    end

    def image_path(path, options = {})
      "/assets/images/#{path}"
    end
  end

  run env
end

map('/')       { run Fortune::App }
map('/api/v1') { run Fortune::Api }
