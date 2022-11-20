module IcalFilterProxy
  class Calendar
    attr_accessor :ical_url, :api_key, :timezone, :filter_rules, :mappings

    def initialize(ical_url, api_key, timezone = 'UTC')
      self.ical_url = ical_url
      self.api_key = api_key
      self.timezone = timezone

      self.filter_rules = []
      self.mappings = []
    end

    def add_rule(field, operator, value)
      self.filter_rules << FilterRule.new(field, operator, value)
    end

    def add_mapping(field, rules, value)
      self.mappings << Mapping.new(field, rules, value)
    end

    def filtered_calendar
      filtered_calendar = Icalendar::Calendar.new
      filtered_events.each do |original_event|
        mapped_event = original_event
        mappings.each do |mapping|
          mapped_event.send(mapping.field + "=", mapping.value) if mapping_match?(mapping, FilterableEventAdapter.new(original_event, timezone: timezone))
        end
        filtered_calendar.add_event(mapped_event)
      end
      filtered_calendar.to_ical
    end

    private

    def filtered_events
      original_ics.events.select do |e|
        filter_match?(FilterableEventAdapter.new(e, timezone: timezone))
      end
    end

    def filter_match?(event)
      filter_rules.empty? || filter_rules.all? { |rule| rule.match_event?(event) }
    end

    def mapping_match?(mapping, event)
      mapping.rules.empty? || mapping.rules.all? { |rule| rule.match_event?(event) }
    end

    def original_ics
      Icalendar::Calendar.parse(raw_original_ical).first
    end

    def raw_original_ical
      URI.open(ical_url).read
    end
  end
end
