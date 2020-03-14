namespace :lambda do
  task :build do
    abort("Please add a config.yml before continuing") unless File.exists?(File.expand_path('config.yml', __dir__))

    STDOUT.puts "Fetching dependencies"
    `bundle install --deployment`

    STDOUT.puts "Creating archive"
    `cd #{File.expand_path(__dir__)} && zip -r ical-filter-proxy.zip *`

    STDOUT.puts "Cleaning up"
    `rm -rf #{File.expand_path('vendor', __dir__)}`
  end
end
