module IcalFilterProxy
  class FilterRule
    attr_accessor :field, :operator, :value

    def intialize(field, operator, val)
      self.field = field
      self.operator = operator
      self.val = val
    end

    def match_event?(event)
      true
    end
  end
end
