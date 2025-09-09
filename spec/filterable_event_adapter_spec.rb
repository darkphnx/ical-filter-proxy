require 'spec_helper'

RSpec.describe IcalProxy::FilterableEventAdapter do
  let(:start_time) { Time.new(1987, 2, 21, 4, 30, 0, 0) }
  let(:end_time) { Time.new(2017, 6, 29, 23, 59, 0, 0) }
  let(:summary) { "The life and times of Dan" }
  let(:description) { "A 30 year event does seem a little excessive, doesn't it?" }

  let(:test_event) do
    event = Icalendar::Event.new
    event.dtstart = start_time
    event.dtend = end_time
    event.summary = summary
    event.description = description
    event
  end

  describe '.new' do
    it 'accepts an event as its first arg' do
      adapter = described_class.new(test_event)
      expect(adapter.raw_event).to eq(test_event)
    end

    it 'accepts an optional timezone in an options hash' do
      adapter = described_class.new(test_event, timezone: 'Europe/London')
      expect(adapter.options[:timezone]).to eq('Europe/London')
    end

    it 'defaults to UTC as a timezone' do
      adapter = described_class.new(test_event)
      expect(adapter.options[:timezone]).to eq('UTC')
    end
  end

  describe '#start_time' do
    it 'translates dtstart into a zero padded 24h timestamp' do
      adapter = described_class.new(test_event)
      expect(adapter.start_time).to eq("04:30")
    end

    it 'uses the timezone specified in the options hash' do
      tz = 'Europe/Moscow'
      expected_time = start_time.in_time_zone(tz).strftime("%H:%M")

      adapter = described_class.new(test_event, timezone: tz)
      expect(adapter.start_time).to eq(expected_time)
    end
  end

  describe '#end_time' do
    it 'translates dtend into a zero padded 24h timestamp' do
      adapter = described_class.new(test_event)
      expect(adapter.end_time).to eq("23:59")
    end

    it 'uses the timezone specified in the options hash' do
      tz = 'Europe/Moscow'
      expected_time = end_time.in_time_zone(tz).strftime("%H:%M")

      adapter = described_class.new(test_event, timezone: tz)
      expect(adapter.end_time).to eq(expected_time)
    end
  end

  describe '#start_date' do
    it 'translates dtstart into a date only' do
      adapter = described_class.new(test_event)
      expect(adapter.start_date).to eq("1987-02-21")
    end

    it 'uses the timezone specified in the options hash' do
      tz = 'Europe/Moscow'
      adapter = described_class.new(test_event, timezone: tz)
      expect(adapter.start_date).to eq('1987-02-21')
    end
  end

  describe '#end_date' do
    it 'translates dtend into a date only' do
      adapter = described_class.new(test_event)
      expect(adapter.end_date).to eq("2017-06-29")
    end

    it 'uses the timezone specified in the options hash' do
      tz = 'Europe/Moscow'
      adapter = described_class.new(test_event, timezone: tz)
      expect(adapter.end_date).to eq('2017-06-30')
    end
  end
end
