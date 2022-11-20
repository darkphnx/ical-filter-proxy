module IcalFilterProxy
  class Mapping

    attr_accessor :field, :rules, :value

    def initialize(field, rules, value)
      self.field = field
      self.rules = rules
      self.value = value
    end

    def match_event?(filterable_event)
      rules.match_event?(filterable_event)
    end
  end
end
