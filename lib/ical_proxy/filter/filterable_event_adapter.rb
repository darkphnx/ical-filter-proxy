module IcalProxy
  # Wraps an Icalendar::Event and exposes filterable properties such as start_time or end_time.
  class FilterableEventAdapter
    attr_reader :raw_event, :options

    extend Forwardable
    def_delegators :raw_event, :dtstart, :dtend, :summary, :description

    def initialize(raw_event, options = {})
      @raw_event = raw_event
      @options = { timezone: 'UTC' }.merge(options)
    end

    # Wraps a DateTime and exposes filterable parts of that time stamp. Avoids writing methods for every dtstart and
    # dtend component that might be queried.
    class DateComponents
      TIME_FORMAT = "%H:%M".freeze
      DATE_FORMAT = "%Y-%m-%d".freeze

      attr_reader :timestamp

      def initialize(timestamp, timezone)
        @timestamp = timestamp.in_time_zone(timezone)
      end

      # @return [String] time component only in the format "HH:MM"
      def time
        @time ||= timestamp.strftime(TIME_FORMAT)
      end

      # @return [String] time component only in the format "YYYY-MM-DD"
      def date
        @date ||= timestamp.strftime(DATE_FORMAT)
      end
    end

    # @private We need to use send from method_missing to obtain this, so we can't use private, but this isn't for you
    def start_components
      @start_components ||= DateComponents.new(dtstart, options[:timezone])
    end

    # @private We need to use send from method_missing to obtain this, so we can't use private, but this isn't for you
    def end_components
      @end_components ||= DateComponents.new(dtend, options[:timezone])
    end

    def method_missing(method_sym, *args, &block)
      if method_sym.to_s =~ /(start|end)\_(\w+)/
        components = self.send("#{$1}_components")
        components.send($2)
      else
        super
      end
    end

    def respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /(start|end)\_(\w+)/
        DateComponents.method_defined?($2.to_sym)
      else
        super
      end
    end
  end
end
