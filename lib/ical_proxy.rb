require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'icalendar'
require 'yaml'
require 'forwardable'
require 'to_regexp'

require_relative 'ical_proxy/filter/alarm_trigger'
require_relative 'ical_proxy/calendar'
require_relative 'ical_proxy/filter/filter_rule'
require_relative 'ical_proxy/calendar_builder'
require_relative 'ical_proxy/filter/filterable_event_adapter'
require_relative 'ical_proxy/transformer/rename'
require_relative 'ical_proxy/transformer/location_rules'

module IcalProxy
  def self.calendars
    config.transform_values do |calendar_config|
      CalendarBuilder.new(calendar_config).build
    end
  end

  def self.config
    content = File.read(config_file_path, :encoding => 'UTF-8')
    content.gsub! /\${(ICAL_PROXY_[^}]+)}/ do
      ENV[$1]
    end
    YAML.safe_load(content)
  end

  def self.config_file_path
    File.expand_path('../config.yml', __dir__)
  end

end
