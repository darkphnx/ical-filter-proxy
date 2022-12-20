require 'rack'
require_relative 'lib/ical_filter_proxy'
require_relative 'lib/ical_filter_proxy/servers/rack_app'

calendars = IcalFilterProxy.calendars
app = IcalFilterProxy::Servers::RackApp.new(calendars)

run app
