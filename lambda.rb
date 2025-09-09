require_relative 'lib/ical_proxy'
require_relative 'lib/ical_proxy/servers/lambda_app'

# Entry point for AWS Lambda

def handle(event:, context:)
  calendars = IcalProxy.calendars
  app = IcalProxy::Servers::LambdaApp.new(calendars)

  app.call(event)
end
