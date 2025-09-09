require 'spec_helper'

RSpec.describe IcalProxy::CalendarBuilder do

  subject { described_class.new(example_config) }

  let(:example_config) do
    {
      'ical_url' => 'https://url-to-calendar.ical',
      'api_key' => 'abc12',
      'rules' => [
        { 'field' => 'start_time', 'operator' => 'equals', 'val' => '09:00' }
      ],
      'alarms' => {
        'clear_existing' => true,
        'triggers'=> [ '10 days' ]
      }
    }
  end

  describe '#build' do
    let(:calendar) { subject.build }

    it 'builds a Calendar' do
      expect(calendar).to be_a(IcalProxy::Calendar)
    end

    it 'adds ical_url to the Calendar object' do
      expect(calendar.ical_url).to eq('https://url-to-calendar.ical')
    end

    it 'adds api_key to the Calenar object' do
      expect(calendar.api_key).to eq('abc12')
    end

    it 'adds filter rules to the Calendar object' do
      filter_rule = calendar.filter_rules.first

      expect(filter_rule).to be_a(IcalProxy::FilterRule)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq('09:00')
    end

    it 'sets clear alarms flag on the Calendar object' do
      expect(calendar.clear_existing_alarms).to eq(true)
    end

    it 'adds alarm triggers to the Calendar object' do
      alarm_trigger = calendar.alarm_triggers.first

      expect(alarm_trigger).to be_a(IcalProxy::AlarmTrigger)
      expect(alarm_trigger.alarm_trigger).to eq('-P10D')
    end

    context 'when no filter rules are present' do
      let(:example_config) do
        {
          'ical_url' => 'https://url-to-calendar.ical',
          'api_key' => 'abc12',
        }
      end

      it 'does not attempt to add any rules' do
        expect(calendar.filter_rules).to be_empty
      end

    end

    context 'when no alarms are present' do
      let(:example_config) do
        {
          'ical_url' => 'https://url-to-calendar.ical',
          'api_key' => 'abc12',
        }
      end

      it 'does not attempt to add any alarm' do
        expect(calendar.alarm_triggers).to be_empty
      end

      it 'does not set clear alarms flag' do
        expect(calendar.clear_existing_alarms).to eq(false)
      end

    end
  end

end
