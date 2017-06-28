require 'spec_helper'

RSpec.describe IcalFilterProxy::Calendar do
  let(:url) { 'http://example.com/ical.ics' }
  let(:cal) { described_class.new(url) }

  describe '.new' do
    it 'accepts a URL as its first arg' do
      cal = described_class.new(url)

      expect(cal.ical_url).to eq(url)
    end

    it 'sets UTC as the default timezone' do
      expect(cal.timezone).to eq('UTC')
    end

    it 'optionally accepts a timezone as its second arg' do
      tz = 'Europe/London'
      cal = described_class.new(url, tz)

      expect(cal.timezone).to eq(tz)
    end

    it 'starts with an empty array of filter rules' do
      expect(cal.filter_rules.length).to eq(0)
    end

    describe '#add_rule' do
      it 'adds a new rule to the filter_rules array' do
        cal.add_rule('start_time', 'equals', '09:00')

        expect(cal.filter_rules.length).to eq(1)
      end
    end

    describe '#filtered_calendar' do
      before(:each) do
        @stub = stub_request(:get, "http://example.com/ical.ics").to_return(body: original_calendar)
      end

      it 'fetches the original calendar from the ical_url' do
        cal.filtered_calendar
        expect(@stub).to have_been_requested
      end

      it 'outputs a fresh calendar with only the events that match the filter_rules' do
        cal.add_rule('start_time', 'equals', '10:00')

        filtered_ical = cal.filtered_calendar
        expect(filtered_ical).to eq(filtered_calendar)
      end
    end
  end

  private

  def original_calendar
    File.read(File.expand_path('../fixtures/original_calendar.ics', __FILE__))
  end

  def filtered_calendar
    File.read(File.expand_path('../fixtures/filtered_calendar.ics', __FILE__))
  end
end
