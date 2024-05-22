require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'
require 'forwardable'
require 'to_regexp'

require_relative 'ical_filter_proxy/alarm_trigger'
require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/calendar_builder'
require_relative 'ical_filter_proxy/filterable_event_adapter'

module IcalFilterProxy
  def self.calendars
    config.transform_values do |calendar_config|
      CalendarBuilder.new(calendar_config).build
    end
  end

  def self.config
    content = File.read(config_file_path, :encoding => 'UTF-8')
    content.gsub! /\${(ICAL_FILTER_PROXY_[^}]+)}/ do
      ENV[$1]
    end
    YAML.safe_load(content)
  end

  def self.config_file_path
    File.expand_path('../config.yml', __dir__)
  end

end
