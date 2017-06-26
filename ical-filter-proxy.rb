require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'

module IcalFilterProxy
  class Filter
    attr_accessor :name, :ical_url, :filter_rules

    def initialize(name, ical_url, filter_rules = [])
      self.name = name
      self.ical_url = ical_url
      self.filter_rules = filter_rules
    end

    def filtered_calendar
      filtered_calendar = Icalendar::Calendar.new
      original_ics.events.select { |e| filter_match?(e) }.each do |original_event|
        filtered_calendar.add_event(original_event)
      end
      filtered_calendar.to_ical
    end

    private

    def filter_match?(event)
      filter_rules.empty? || filter_rules.all? { |rule| rule.match_event?(event) }
    end

    def original_ics
      Icalendar::Calendar.parse(raw_original_ical).first
    end

    def raw_original_ical
      open(ical_url).read
    end
  end

  class FilterRule
    attr_accessor :field, :operator, :value

    def intialize(field, operator, val)
      self.field = field
      self.operator = operator
      self.val= val
    end

    def match_event?(event)
      true
    end
  end

  class FilterProxy
    attr_accessor :filters

    def initialize(filters)
      self.filters = filters
    end

    def call(env)
      request = Rack::Request.new(env)

      requested_filter = request.path_info.sub(/^\//, '')
      ical_filter = filters[requested_filter]

      if ical_filter
        if request.params['key'] == ical_filter[:api_key]
          [200, {'Content-Type' => 'text/calendar'}, [ical_filter[:filter].filtered_calendar]]
        else
          [403, {'Content-Type' => 'text/plain'}, ['Authentication Incorrect']]
        end
      else
        [404, {'Content-Type' => 'text/plain'}, ['Calendar not found']]
      end
    end

    private

    def find_filter(filter_name)
      filters.find { |filter| filter.name == filter_name }
    end
  end

  def self.start
    config_file_path = File.expand_path('../config.yml', __FILE__)
    config = YAML.load(open(config_file_path))

    filters = Hash.new({})
    config.each do |filter_name, filter_config|
      rules = filter_config["rules"].map { |rule| FilterRule.new(rule["field"], rule["operator"], rule["val"]) }
      filters[filter_name][:filter] = Filter.new(filter_name, filter_config["ical_url"], rules)

      filters[filter_name][:api_key] = filter_config["api_key"]
    end

    FilterProxy.new(filters)
  end
end
