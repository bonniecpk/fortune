@dir = "/srv/fortune/current/"

worker_processes 2
working_directory @dir
timeout 30
preload_app false

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "localhost:8090", :backlog => 64

# Set process id path
pid "#{@dir}tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"
