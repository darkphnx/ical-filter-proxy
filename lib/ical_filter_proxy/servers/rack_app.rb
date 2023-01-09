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

        if requested_calendar.strip.empty?
          return [200, { 'content-type' => 'text/plain' }, ['Welcome to ical-filter-proxy']]
        end

        ical_calendar = calendars[requested_calendar]

        if ical_calendar
          if request.params['key'] == ical_calendar.api_key
            [200, { 'content-type' => 'text/calendar' }, [ical_calendar.filtered_calendar]]
          else
            [403, { 'content-type' => 'text/plain' }, ['Authentication Incorrect']]
          end
        else
          [404, { 'content-type' => 'text/plain' }, ['Calendar not found']]
        end
      end
    end
  end
end
