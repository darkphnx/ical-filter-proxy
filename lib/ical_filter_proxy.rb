require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'

require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/filterable_event_adapter'
require_relative 'ical_filter_proxy/rack_app'

module IcalFilterProxy
  def self.start_rack_app
    RackApp.new(filters)
  end

  def self.filters
    config.each_with_object({}) do |(filter_name, filter_config), filters|
      calendar = Calendar.new(filter_config["ical_url"], filter_config["timezone"])

      filter_config["rules"].each do |rule|
        calendar.add_rule(rule["field"], rule["operator"], rule["val"])
      end

      filters[filter_name] = {
        calendar: calendar,
        api_key: filter_config["api_key"]
      }
    end
  end

  def self.config
    config_file_path = File.expand_path('../config.yml', __dir__)
    YAML.safe_load(File.read(config_file_path))
  end
end
