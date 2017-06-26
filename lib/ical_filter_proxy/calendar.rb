module IcalFilterProxy
  class Calendar
    attr_accessor :ical_url, :timezone, :filter_rules

    def initialize(ical_url, timezone = 'UTC')
      self.ical_url = ical_url
      self.timezone = timezone
      self.filter_rules = []
    end

    def add_rule(field, operator, value)
      self.filter_rules << FilterRule.new(self, field, operator, value)
    end

    def filtered_calendar
      filtered_calendar = Icalendar::Calendar.new
      original_ics.events.select { |e| filter_match?(e) }.each do |original_event|
        filtered_calendar.add_event(original_event)
      end
      filtered_calendar.to_ical
    end

    private

    def filter_match?(event)
      filter_rules.empty? || filter_rules.all? { |rule| rule.match_event?(event) }
    end

    def original_ics
      Icalendar::Calendar.parse(raw_original_ical).first
    end

    def raw_original_ical
      open(ical_url).read
    end
  end
end
