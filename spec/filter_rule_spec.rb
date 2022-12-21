require 'spec_helper'

RSpec.describe IcalFilterProxy::FilterRule do
  describe '.new' do
    it 'accepts field, operator and value' do
      filter_rule = described_class.new('start_time', 'equals', '09:00')

      expect(filter_rule).to be_a(described_class)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.negation).to eq(false)
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq('09:00')
    end

    it 'accepts field, negative operator and value' do
      filter_rule = described_class.new('start_time', 'not-equals', '09:00')

      expect(filter_rule).to be_a(described_class)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.negation).to eq(true)
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq('09:00')
    end

    it 'accepts field, operator and value array' do
      filter_rule = described_class.new('start_time', 'equals', ['09:00', '10:00'])

      expect(filter_rule).to be_a(described_class)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.negation).to eq(false)
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq(['09:00', '10:00'])
    end
  end

  describe '#match_event?' do
    let(:dummy_event) { instance_double("FilterableEventAdapter", :event, start_time: '09:00', summary: 'Foobar') }

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

    context 'when operator is startswith and value an array' do
      it 'matches events where the value is the same as the filter value' do
        matching_filter_rule = described_class.new('summary', 'startswith', ['Foo', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value is different to the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'startswith', ['Bar', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when operator is not-startswith and value an array' do
      it 'matches events where the value does not start with the filter value' do
        matching_filter_rule = described_class.new('summary', 'not-startswith', ['Bar', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value starts with the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'not-startswith', ['Foo', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when operator is includes and value an array' do
      it 'matches events where the value is part of the filter value' do
        matching_filter_rule = described_class.new('summary', 'includes', ['oob', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value is not part of to the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'includes', ['Bar', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when operator is not-includes and value an array' do
      it 'matches events where the value does not contain the filter value' do
        matching_filter_rule = described_class.new('summary', 'not-includes', ['Bar', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the value contains the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'not-includes', ['oob', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when operator is matches and value an array' do
      it 'matches events where the pattern is matching the filter value' do
        matching_filter_rule = described_class.new('summary', 'includes', ['/foobar/i', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'matches events where the more complex pattern is matching the filter value' do
        matching_filter_rule = described_class.new('summary', 'includes', ['/^Foo[bB]a.$/', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the pattern is not matching of to the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'includes', ['/foobar/', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

    context 'when operator is not-matches and value an array' do
      it 'matches events where the pattern does not match the filter value' do
        matching_filter_rule = described_class.new('summary', 'not-includes', ['/foobar/', 'Nothing'])
        expect(matching_filter_rule.match_event?(dummy_event)).to be true
      end

      it 'rejects events where the pattern matches the filter value' do
        non_matching_filter_rule = described_class.new('summary', 'not-includes', ['/foobar/i', 'Nothing'])
        expect(non_matching_filter_rule.match_event?(dummy_event)).to be false
      end
    end

  end
end
