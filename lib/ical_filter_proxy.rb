require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'

require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/filterable_event_adapter'
require_relative 'ical_filter_proxy/web_app'

module IcalFilterProxy
  def self.start
    filters = {}
    config.each do |filter_name, filter_config|
      calendar = Calendar.new(filter_config["ical_url"], filter_config["timezone"])
      filter_config["rules"].each do |rule|
        calendar.add_rule(rule["field"], rule["operator"], rule["val"])
      end

      filters[filter_name] = {
        calendar: calendar,
        api_key: filter_config["api_key"]
      }
    end

    WebApp.new(filters)
  end

  def self.config
    config_file_path = File.expand_path('../../config.yml', __FILE__)
    config = YAML.load(open(config_file_path))
  end
end
