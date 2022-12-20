require_relative 'lib/ical_filter_proxy'
require_relative 'lib/ical_filter_proxy/servers/lambda_app'

# Entry point for AWS Lambda

def handle(event:, context:)
  calendars = IcalFilterProxy.calendars
  app = IcalFilterProxy::Servers::LambdaApp.new(calendars)

  app.call(event)
end
