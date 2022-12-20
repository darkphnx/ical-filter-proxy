require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'
require 'forwardable'

require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/filterable_event_adapter'

module IcalFilterProxy
  def self.calendars
    config.each_with_object({}) do |(calendar_name, filter_config), calendars|
      calendar = Calendar.new(filter_config["ical_url"], filter_config["api_key"], filter_config["timezone"])

      filter_config["rules"].each do |rule|
        calendar.add_rule(rule["field"], rule["operator"], rule["val"])
      end

      calendars[calendar_name] = calendar
    end
  end

  def self.config
    YAML.safe_load(File.read(config_file_path))
  end

  def self.config_file_path
    File.expand_path('../config.yml', __dir__)
  end
end
