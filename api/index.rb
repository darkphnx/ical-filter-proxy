require_relative '../lib/ical_filter_proxy'
require_relative '../lib/ical_filter_proxy/servers/vercel_app'

Handler = Proc.new do |request, response|
  calendars = IcalFilterProxy.calendars
  app = IcalFilterProxy::Servers::VercelApp.new(calendars)

  app.call(request, response)
end
