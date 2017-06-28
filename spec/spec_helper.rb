require 'rspec'
require 'webmock/rspec'
require 'ical_filter_proxy'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use the specified formatter
  config.formatter = :documentation
end

WebMock.disable_net_connect!(allow_localhost: true)
