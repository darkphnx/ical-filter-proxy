require_relative '../lib/ical_proxy'
require_relative '../lib/ical_proxy/servers/vercel_app'

Handler = Proc.new do |request, response|
  calendars = IcalProxy.calendars
  app = IcalProxy::Servers::VercelApp.new(calendars)

  app.call(request, response)
end
