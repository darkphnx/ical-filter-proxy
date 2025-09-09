require_relative './lib/ical_proxy'
require_relative './lib/ical_proxy/servers/puma_app'

run IcalProxy::Servers::PumaApp.new(IcalProxy.calendars)

