module IcalFilterProxy
  class FilterRule
    TIME_FORMAT = "%H:%M".freeze

    attr_accessor :calendar, :field, :operator, :val

    def initialize(calendar, field, operator, val)
      self.calendar = calendar
      self.field = field
      self.operator = operator
      self.val = val
    end

    def match_event?(event)
      event_data = data_for(field, event)

      puts "#{event_data} #{val} #{operator}"

      case operator
      when 'equals'
        event_data == val
      when 'not-equals'
        event_data != val
      else
        false
      end
    end

    private

    def data_for(field, event)
      case field
      when 'start_time'
        event.dtstart.in_time_zone(timezone).strftime(TIME_FORMAT)
      when 'end_time'
        event.dtend.in_time_zone(timezone).strftime(TIME_FORMAT)
      end
    end

    def timezone
      calendar.timezone
    end
  end
end
