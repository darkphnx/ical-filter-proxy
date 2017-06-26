module IcalFilterProxy
  class Calendar
    attr_accessor :name, :ical_url, :filter_rules

    def initialize(name, ical_url, filter_rules = [])
      self.name = name
      self.ical_url = ical_url
      self.filter_rules = filter_rules
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
