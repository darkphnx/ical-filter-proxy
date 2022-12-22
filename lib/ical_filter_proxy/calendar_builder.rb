module IcalFilterProxy
  class CalendarBuilder

    attr_reader :calendar_config, :calendar

    def initialize(calendar_config)
      @calendar_config = calendar_config
    end

    def build
      create_calendar
      add_rules
      add_alarms

      calendar
    end

    private

    def create_calendar
      @calendar = Calendar.new(calendar_config["ical_url"],
                               calendar_config["api_key"],
                               calendar_config["timezone"])
    end

    def add_rules
      rules = calendar_config["rules"]
      return unless rules

      rules.each do |rule|
        calendar.add_rule(rule["field"],
                          rule["operator"],
                          rule["val"])
      end
    end

    def add_alarms
      alarms = calendar_config["alarms"]
      return unless alarms

      if alarms["clear_existing"] == true
        calendar.clear_existing_alarms = true
      end

      triggers = alarms["triggers"]
      return unless triggers

      triggers.each do |trigger|
        calendar.add_alarm_trigger(generate_iso_format(trigger))
        end
    end

    def generate_iso_format(input)
      case input
      when /(\d+)\s+days?/i
        return "-P#{$1}D"
      when /(\d+)\s+hours?/i
        return "-PT#{$1}H"
      when /(\d+)\s+minutes?/i
        return "-PT#{$1}M"
      when /^-P.*/
        return input
      else
        raise "Unknown trigger pattern: " + input
      end
    end

  end
end
