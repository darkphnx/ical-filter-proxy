require 'spec_helper'

require 'spec_helper'

RSpec.describe IcalFilterProxy::CalendarBuilder do

  subject { described_class.new(example_config) }

  describe '#build' do
    let(:calendar) { subject.build }

    it 'builds a Calendar' do
      expect(calendar).to be_a(IcalFilterProxy::Calendar)
    end

    it 'adds ical_url to the Calendar object' do
      expect(calendar.ical_url).to eq('https://url-to-calendar.ical')
    end

    it 'adds api_key to the Calenar object' do
      expect(calendar.api_key).to eq('abc12')
    end

    it 'adds filters to the Calendar object' do
      filter_rule = calendar.filter_rules.first

      expect(filter_rule).to be_a(IcalFilterProxy::FilterRule)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq('09:00')
    end
  end

  def example_config
    {
      'ical_url' => 'https://url-to-calendar.ical',
      'api_key' => 'abc12',
      'rules' => [
        { 'field' => 'start_time', 'operator' => 'equals', 'val' => '09:00' }
      ]
    }
  end

end
