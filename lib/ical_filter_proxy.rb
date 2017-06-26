require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'open-uri'
require 'icalendar'
require 'yaml'

require_relative 'ical_filter_proxy/calendar'
require_relative 'ical_filter_proxy/filter_rule'
require_relative 'ical_filter_proxy/web_app'

module IcalFilterProxy
  def self.start
    config_file_path = File.expand_path('../../config.yml', __FILE__)
    config = YAML.load(open(config_file_path))

    filters = Hash.new({})
    config.each do |filter_name, filter_config|
      rules = filter_config["rules"].map { |rule| FilterRule.new(rule["field"], rule["operator"], rule["val"]) }
      filters[filter_name][:calendar] = Calendar.new(filter_name, filter_config["ical_url"], rules)

      filters[filter_name][:api_key] = filter_config["api_key"]
    end

    WebApp.new(filters)
  end
end
