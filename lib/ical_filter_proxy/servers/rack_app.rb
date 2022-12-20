module IcalFilterProxy
  module Servers
    class RackApp
      attr_accessor :calendars

      def initialize(calendars)
        self.calendars = calendars
      end

      def call(env)
        request = Rack::Request.new(env)

        requested_calendar = request.path_info.sub(/^\//, '')
        ical_calendar = calendars[requested_calendar]

        if ical_calendar
          if request.params['key'] == ical_calendar.api_key
            [200, { 'Content-Type' => 'text/calendar' }, [ical_calendar.filtered_calendar]]
          else
            [403, { 'Content-Type' => 'text/plain' }, ['Authentication Incorrect']]
          end
        else
          [404, { 'Content-Type' => 'text/plain' }, ['Calendar not found']]
        end
      end
    end
  end
end
