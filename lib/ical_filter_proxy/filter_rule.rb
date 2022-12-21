module IcalFilterProxy
  class FilterRule

    attr_accessor :field, :operator, :values, :negation

    def initialize(field, operator, values)
      self.field = field
      operator =~ /^(not-)?(\w+)/
      self.negation = !$1.nil?
      self.operator = $2
      self.values = values
    end

    def match_event?(filterable_event)
      event_data = filterable_event.send(field.to_sym)
      negation ^ evaluate(event_data, values)
    end

    private

    def evaluate(event_data, value)
      if value.is_a? Array
        value.reduce(false) { |r, v| r |= evaluate(event_data, v) }
      else
        case operator
        when 'equals'
          event_data == value
        when 'startswith'
          event_data.start_with?(value)
        when 'includes'
          event_data.include?(value)
        when 'matches'
          event_data =~ Regexp.new(value)
        else
          false
        end
      end
    end
  end
end
