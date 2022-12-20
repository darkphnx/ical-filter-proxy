require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'
require 'forwardable'

require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/mapping'
require_relative 'ical_filter_proxy/filterable_event_adapter'

module IcalFilterProxy
  def self.filters
    config.each_with_object({}) do |(filter_name, filter_config), filters|
      calendar = Calendar.new(filter_config["ical_url"], filter_config["api_key"], filter_config["timezone"])

      filter_config["rules"].each do |rule|
        calendar.add_rule(rule["field"], rule["operator"], rule["val"])
      end unless filter_config["rules"].nil?

      filter_config["map"].each do |mapping|
        rules = []

        mapping["rules"].each do |rule|
          rules << FilterRule.new(rule["field"], rule["operator"], rule["val"])
        end

        calendar.add_mapping(mapping["field"], rules, mapping["val"])
      end unless filter_config["map"].nil?

      filters[filter_name] = calendar
    end
  end

  def self.config
    YAML.safe_load(File.read(config_file_path))
  end

  def self.config_file_path
    File.expand_path('../config.yml', __dir__)
  end
end
