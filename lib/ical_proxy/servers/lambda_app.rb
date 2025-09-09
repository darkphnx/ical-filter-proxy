module IcalProxy
  module Servers
    class LambdaApp
      attr_accessor :calendars

      def initialize(calendars)
        self.calendars = calendars
      end

      def call(event)
        return render_not_found unless event['queryStringParameters']

        calendar_name = event['queryStringParameters']['calendar']
        ical_calendar = calendars[calendar_name]

        if ical_calendar
          if event['queryStringParameters']['key'] == ical_calendar.api_key
            render_calendar(ical_calendar)
          else
            render_forbidden
          end
        else
          render_not_found
        end
      end

      private

      def render_calendar(calendar)
        { statusCode: 200, headers: { 'content-type' => 'text/calendar' }, body: calendar.proxied_calendar }
      end

      def render_not_found
        { statusCode: 404, headers: { 'content-type' => 'text/plain' }, body: 'Calendar not found' }
      end

      def render_forbidden
        { statusCode: 403, headers: { 'content-type' => 'text/plain' }, body: "Authentication incorrect" }
      end
    end
  end
end
