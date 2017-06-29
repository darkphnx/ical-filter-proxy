module IcalFilterProxy
  class FilterRule

    attr_accessor :calendar, :field, :operator, :val

    def initialize(calendar, field, operator, val)
      self.calendar = calendar
      self.field = field
      self.operator = operator
      self.val = val
    end

    def match_event?(filterable_event)
      event_data = filterable_event.send(field.to_sym)

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

    def timezone
      calendar.timezone
    end
  end
end
