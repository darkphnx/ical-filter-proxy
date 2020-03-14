require_relative 'lib/ical_filter_proxy'
require_relative 'lib/ical_filter_proxy/servers/lambda_app'

# Entry point for AWS Lambda

def handle(event:, context:)
  filters = IcalFilterProxy.filters
  app = IcalFilterProxy::Servers::LambdaApp.new(filters)

  app.call(event)
end
