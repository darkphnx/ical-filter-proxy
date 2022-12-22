module IcalFilterProxy
  class Calendar
    attr_accessor :ical_url, :api_key, :timezone, :filter_rules, :clear_existing_alarms, :alarm_triggers

    def initialize(ical_url, api_key, timezone = 'UTC')
      self.ical_url = ical_url
      self.api_key = api_key
      self.timezone = timezone

      self.filter_rules = []
      self.clear_existing_alarms = false
      self.alarm_triggers = []
    end

    def add_rule(field, operator, value)
      self.filter_rules << FilterRule.new(field, operator, value)
    end

    def add_alarm_trigger(alarm_trigger)
      self.alarm_triggers << alarm_trigger
    end

    def set_clear_existing_alarms
      self.clear_existing_alarms = true
    end

    def filtered_calendar
      filtered_calendar = Icalendar::Calendar.new

      filtered_events.each do |original_event|
        filtered_calendar.add_event(original_event)
      end

      filtered_calendar.events.select do |e|
        e.alarms.clear if clear_existing_alarms
        alarm_triggers.each do |t|
          e.alarm do |a|
            a.action = "DISPLAY"
            a.description = e.summary
            a.trigger = t
          end
        end
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

    def original_ics
      Icalendar::Calendar.parse(raw_original_ical).first
    end

    def raw_original_ical
      URI.open(ical_url).read
    end
  end
end
