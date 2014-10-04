# config valid only for Capistrano 3.1
lock '3.2.1'

def server_domains(defaults = nil)
  ask(:servers, defaults.kind_of?(Array) ? defaults.join(",") : defaults)
  servers = fetch(:servers)
  servers.split(",").collect { |initial| "#{initial.strip}.pchui.me" }
end

def branch_chooser(env)
  default = `git branch | grep '*' | awk '{print $2}'`.strip
  ask(:branch, default)
  fetch(:branch)
end

set :application, 'fortune'
set :repo_url, 'git@github.com:bonniecpk/fortune.git'

# Use the Ruby defined in the release path, i.e., by the .ruby-version file
set :rvm_ruby_version, '2.1.2@fortune'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/mongoid.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:reload'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
