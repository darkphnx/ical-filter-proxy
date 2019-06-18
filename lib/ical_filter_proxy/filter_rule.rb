module IcalFilterProxy
  class FilterRule

    attr_accessor :field, :operator, :value, :negation

    def initialize(field, operator, value)
      self.field = field
      operator =~ /^(not-)?(\w+)/
      self.negation = !$1.nil?
      self.operator = $2
      self.value = value
    end

    def match_event?(filterable_event)
      event_data = filterable_event.send(field.to_sym)
      negation ^ evaluate(event_data)
    end

    private

    def evaluate(event_data)
      case operator
      when 'equals'
        event_data == value
      when 'startswith'
        event_data.start_with?(value)
      else
        false
      end
    end
  end
end
