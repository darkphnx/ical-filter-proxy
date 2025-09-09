require 'spec_helper'

RSpec.describe IcalProxy::AlarmTrigger do
  describe '.new' do
    it 'accepts valid iso trigger' do
      alarm_trigger = described_class.new("-P1DT1H1M2S")

      expect(alarm_trigger).to be_a(described_class)
      expect(alarm_trigger.alarm_trigger).to eq("-P1DT1H1M2S")
    end

    it 'accepts valid day trigger' do
      alarm_trigger = described_class.new("10 days")

      expect(alarm_trigger).to be_a(described_class)
      expect(alarm_trigger.alarm_trigger).to eq("-P10D")
    end

    it 'accepts valid hour trigger' do
      alarm_trigger = described_class.new("5 hours")

      expect(alarm_trigger).to be_a(described_class)
      expect(alarm_trigger.alarm_trigger).to eq("-PT5H")
    end

    it 'accepts valid minute trigger' do
      alarm_trigger = described_class.new("10 minutes")

      expect(alarm_trigger).to be_a(described_class)
      expect(alarm_trigger.alarm_trigger).to eq("-PT10M")
    end

    it 'fails on invalid triggers' do
      expect { described_class.new("lorem ipsum") }.to raise_error
      expect { described_class.new("-10 days") }.to raise_error
      expect { described_class.new("PT10M") }.to raise_error
      expect { described_class.new("5 days 10 minutes") }.to raise_error
    end

  end
end
