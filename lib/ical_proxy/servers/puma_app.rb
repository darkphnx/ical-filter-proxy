require 'cgi'

module IcalProxy
  module Servers
    class PumaApp
      attr_accessor :calendars

      def initialize(calendars)
        self.calendars = calendars
      end

      def call(env)
        path = env['PATH_INFO'].to_s
        requested_calendar = path.sub(/^\//, '')

        return ok('Welcome to ical-proxy') if requested_calendar.strip.empty?

        ical_calendar = calendars[requested_calendar]
        return not_found unless ical_calendar

        params = parse_query(env['QUERY_STRING'])

        if params['key'] == ical_calendar.api_key
          [200, { 'content-type' => 'text/calendar' }, [ical_calendar.proxied_calendar]]
        else
          forbidden
        end
      end

      private

      def parse_query(qs)
        return {} unless qs && !qs.empty?
        CGI.parse(qs).transform_values { |v| v.is_a?(Array) ? v.first : v }
      end

      def ok(body)
        [200, { 'content-type' => 'text/plain' }, [body]]
      end

      def not_found
        [404, { 'content-type' => 'text/plain' }, ['Calendar not found']]
      end

      def forbidden
        [403, { 'content-type' => 'text/plain' }, ['Authentication Incorrect']]
      end
    end
  end
end
