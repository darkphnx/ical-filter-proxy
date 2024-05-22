module IcalFilterProxy
  module Servers
    class VercelApp
      attr_accessor :calendars

      def initialize(calendars)
        self.calendars = calendars
      end

      def call(request, response)
        calendar_name = request.query['calendar']

        return render_not_found(response) unless calendar_name

        ical_calendar = calendars[calendar_name]

        if ical_calendar
          if request.query['key'] == ical_calendar.api_key
            render_calendar(ical_calendar, response)
          else
            render_forbidden(response)
          end
        else
          render_not_found(response)
        end
      end

      private

      def render_calendar(calendar, response)
        response.status = 200
        response['Content-Type'] = 'text/calendar'
        response.body = calendar.filtered_calendar
      end

      def render_not_found(response)
        response.status = 404
        response['Content-Type'] = 'text/plain'
        response.body = 'Calendar not found'
      end

      def render_forbidden(response)
        response.status = 403
        response['Content-Type'] = 'text/plain'
        response.body = 'Authentication incorrect'
      end
    end
  end
end
