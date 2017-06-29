module IcalFilterProxy
  # Wraps an Icalendar::Event and exposes filterable properties such as start_time or end_time.
  class FilterableEventAdapter
    TIME_FORMAT = "%H:%M".freeze

    attr_reader :raw_event, :options

    extend Forwardable
    def_delegators :raw_event, :dtstart, :dtend, :summary, :description

    def initialize(raw_event, options = {})
      @raw_event = raw_event
      @options = { timezone: 'UTC' }.merge(options)
    end

    def start_time
      strftime(dtstart)
    end

    def end_time
      strftime(dtend)
    end

    private

    def strftime(timestamp)
      timestamp.in_time_zone(options[:timezone]).strftime(TIME_FORMAT)
    end
  end
end
