require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'
require 'forwardable'
require 'to_regexp'

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
    YAML.safe_load(File.read(config_file_path))
  end

  def self.config_file_path
    File.expand_path('../config.yml', __dir__)
  end
end
