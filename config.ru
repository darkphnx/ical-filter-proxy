require_relative 'lib/ical_filter_proxy'
require_relative 'lib/ical_filter_proxy/servers/rack_app'

filters = IcalFilterProxy.filters
app = IcalFilterProxy::Servers::RackApp.new(filters)

run app
