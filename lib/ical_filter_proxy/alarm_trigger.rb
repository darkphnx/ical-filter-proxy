module IcalFilterProxy
  class AlarmTrigger

    attr_accessor :alarm_trigger

    def initialize(input_trigger)
      self.alarm_trigger = generate_iso_format(input_trigger)
    end

    private

    def generate_iso_format(alarm_trigger)
      case alarm_trigger
      when /^(\d+)\s+days?$/i
        "-P#{$1}D"
      when /^(\d+)\s+hours?$/i
        "-PT#{$1}H"
      when /^(\d+)\s+minutes?$/i
        "-PT#{$1}M"
      when /^-P.*/
        alarm_trigger
      else
        raise "Unknown trigger pattern: #{alarm_trigger}"
      end
    end

  end
end
