module IcalProxy
  module Transformer
    class LocationRules
      Rule = Struct.new(
        :pattern, :search_in, :set_location, :geo,
        :extract_from, :capture_group, :set_if_blank
      )

      def initialize(rules)
        @rules = rules
      end

      def apply(event)
        @rules.each do |rule|
          if rule.extract_from
            apply_extract_rule(event, rule)
          else
            apply_match_rule(event, rule)
          end
        end
      end

      private

      def apply_match_rule(event, rule)
        return unless matches?(event, rule)

        if rule.set_location && !rule.set_location.to_s.empty?
          event.location = rule.set_location
        end

        apply_geo(event, rule.geo)
      end

      def apply_extract_rule(event, rule)
        src = field_value(event, rule.extract_from)
        return if src.empty?

        pat = rule.pattern
        m = pat.is_a?(Regexp) ? src.match(pat) : (src.include?(pat.to_s) && [nil, pat.to_s])
        return unless m

        target = begin
          idx = (rule.capture_group || 1).to_i
          m.is_a?(MatchData) ? m[idx] : m[1]
        rescue
          nil
        end
        return unless target && !target.to_s.empty?

        if rule.set_if_blank
          return unless field_value(event, 'location').strip.empty?
        end

        event.location = target.to_s.strip
        apply_geo(event, rule.geo)
      end

      def matches?(event, rule)
        fields = Array(rule.search_in)
        fields = ['summary'] if fields.empty?

        fields.any? do |field|
          value = field_value(event, field)
          next false if value.empty?

          pat = rule.pattern
          pat.is_a?(Regexp) ? !!value.match(pat) : value.include?(pat.to_s)
        end
      end

      def field_value(event, field)
        case field.to_s
        when 'summary' then event.summary.to_s
        when 'description' then event.description.to_s
        when 'location' then event.location.to_s
        else ''
        end
      end

      def apply_geo(event, geo)
        return unless geo && geo['lat'] && geo['lon']
        event.geo = [geo['lat'], geo['lon']]
      end
    end
  end
end
