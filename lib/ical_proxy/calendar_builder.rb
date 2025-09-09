module IcalProxy
  class CalendarBuilder

    attr_reader :calendar_config, :calendar

    def initialize(calendar_config)
      @calendar_config = calendar_config
    end

    def build
      create_calendar
      add_rules
      add_alarms
      add_transformations

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

      calendar.clear_existing_alarms = true if alarms['clear_existing']

      triggers = alarms["triggers"]
      return unless triggers

      triggers.each do |trigger|
        calendar.add_alarm_trigger(trigger)
      end
    end

    def add_transformations
      cfg = calendar_config["transformations"]
      return unless cfg

      add_rename_transformations(cfg)
      add_location_transformations(cfg)
      add_location_rules_transformations(cfg)
    end

    def add_rename_transformations(cfg)
      rename_rules = cfg["rename"]
      return unless rename_rules.is_a?(Array)

      rename_rules.each do |rule|
        pattern_str = rule["pattern"] || rule["match"] || rule["matches"]
        next unless pattern_str
        replacement = rule["replace"] || rule["replacement"] || rule["to"] || ""

        # Accept several aliases for the fields to search in
        search_in = rule["search_in"] || rule["search"] || rule["in"] || ["summary"]
        # If a capture is requested, default to set_on_match unless explicitly false
        capture_group = rule["capture_group"] || rule["capture"] || (rule["use_capture"] ? 1 : nil)
        set_on_match = if rule.key?("set_on_match")
                         rule["set_on_match"]
                       else
                         (!!rule["to"] || !!rule["normalize"] || !capture_group.nil?)
                       end

        pattern = begin
          if rule.key?("regex") && rule["regex"] == true
            pattern_str.to_regexp
          elsif pattern_str.is_a?(String) && pattern_str.strip.start_with?("/")
            # Support regex-like strings including flags, e.g. "/foo/i"
            pattern_str.to_regexp
          elsif pattern_str.is_a?(Regexp)
            pattern_str
          else
            pattern_str.to_s
          end
        rescue
          pattern_str.to_s
        end

        calendar.add_transformation(
          IcalProxy::Transformer::Rename.new(
            pattern,
            replacement,
            search_in: search_in,
            set_on_match: set_on_match,
            capture_group: capture_group
          )
        )
      end
    end

    def add_location_rules_transformations(cfg)
      rules_cfg = cfg["location_rules"]
      return unless rules_cfg

      rules = Array(rules_cfg).map do |rule|
        pattern_str = rule["pattern"]
        next nil unless pattern_str

        pattern = begin
          if rule.key?("regex") && rule["regex"] == true
            pattern_str.to_regexp
          elsif pattern_str.is_a?(String) && pattern_str.strip.start_with?("/")
            pattern_str.to_regexp
          elsif pattern_str.is_a?(Regexp)
            pattern_str
          else
            pattern_str.to_s
          end
        rescue
          pattern_str.to_s
        end

        search = rule["search"]
        location = rule["location"]

        geo = if rule["geo"].is_a?(Hash)
                rule["geo"]
              elsif rule.key?("lat") && rule.key?("lon")
                { 'lat' => rule["lat"], 'lon' => rule["lon"] }
              else
                nil
              end

        IcalProxy::Transformer::LocationRules::Rule.new(pattern, search, location, geo)
      end.compact

      return if rules.empty?

      calendar.add_transformation(IcalProxy::Transformer::LocationRules.new(rules))
    end

    def add_location_transformations(cfg)
      unified_cfg = cfg["location"]
      return unless unified_cfg

      rules = Array(unified_cfg).map do |rule|
        pattern_str = rule["pattern"]
        next nil unless pattern_str

        pattern = begin
          if rule.key?("regex") && rule["regex"] == true
            pattern_str.to_regexp
          elsif pattern_str.is_a?(String) && pattern_str.strip.start_with?("/")
            pattern_str.to_regexp
          elsif pattern_str.is_a?(Regexp)
            pattern_str
          else
            pattern_str.to_s
          end
        rescue
          pattern_str.to_s
        end

        if rule["extract_from"]
          IcalProxy::Transformer::LocationRules::Rule.new(
            pattern,
            nil,
            nil,
            extract_geo(rule),
            rule["extract_from"].to_s,
            (rule["capture_group"] || 1),
            rule.key?("set_if_blank") ? !!rule["set_if_blank"] : true
          )
        else
          search = rule["search"]
          location = rule["location"]
          geo = extract_geo(rule)

          IcalProxy::Transformer::LocationRules::Rule.new(
            pattern,
            search,
            location,
            geo,
            nil,
            nil,
            nil
          )
        end
      end.compact

      return if rules.empty?

      calendar.add_transformation(IcalProxy::Transformer::LocationRules.new(rules))
    end

    def extract_geo(rule)
      if rule["geo"].is_a?(Hash)
        rule["geo"]
      elsif rule.key?("lat") && rule.key?("lon")
        { 'lat' => rule["lat"], 'lon' => rule["lon"] }
      else
        nil
      end
    end

  end
end
