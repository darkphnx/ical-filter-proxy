require 'spec_helper'

RSpec.describe IcalFilterProxy::FilterRule do
  describe '.new' do
    it 'accepts field, operatior and value' do
      filter_rule = described_class.new('start_time', 'equals', '09:00')

      expect(filter_rule).to be_a(described_class)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.value).to eq('09:00')
    end
  end

  describe '#match_event?' do
    let(:dummy_event) { instance_double("FilterableEventAdapter", :event, start_time: '09:00') }

    context 'when operator is equals' do
      it 'matches events where the value is the same as the filter value' do
        matching_filter_rule = described_class.new('start_time', 'equals', '09:00')
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value is different to the filter value' do
        non_matching_filter_rule = described_class.new('start_time', 'equals', '11:00')
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when the operator is not-equals' do
      it 'matches events where the value is differrent to the filter value' do
        matching_filter_rule = described_class.new('start_time', 'not-equals', '10:00')
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where he value is the same as the filter value' do
        non_matching_filter_rule = described_class.new('start_time', 'not-equals', '09:00')
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when the operator is startswith' do
      it 'matches events where the value starts with the filter value' do
        matching_filter_rule = described_class.new('start_time', 'startswith', '09')
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value does not start with the filter value' do
        non_matching_filter_rule = described_class.new('start_time', 'startswith', '10')
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when the operator is not-startswith' do
      it 'matches events where the value does not start with the filter value' do
        matching_filter_rule = described_class.new('start_time', 'not-startswith', '08')
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value starts with the filter value' do
        non_matching_filter_rule = described_class.new('start_time', 'not-startswith', '09')
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end
  end
end
