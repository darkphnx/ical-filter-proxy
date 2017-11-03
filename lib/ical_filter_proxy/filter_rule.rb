module IcalFilterProxy
  class FilterRule

    attr_accessor :field, :operator, :value

    def initialize(field, operator, value)
      self.field = field
      self.operator = operator
      self.value = value
    end

    def match_event?(filterable_event)
      event_data = filterable_event.send(field.to_sym)

      case operator
      when 'equals'
        event_data == value
      when 'not-equals'
        event_data != value
      else
        false
      end
    end
  end
end
