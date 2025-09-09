# Puma configuration

environment ENV.fetch('RACK_ENV', 'production')

threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', ENV.fetch('PUMA_MAX_THREADS', 5))) rescue 5
threads threads_count, threads_count

workers Integer(ENV.fetch('WEB_CONCURRENCY', 0)) rescue 0

# Bind to a single TCP socket to avoid double-binding the same port
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 9292)}"

# Use a standard Rackup file for app wiring
rackup 'config.ru'

plugin :tmp_restart
