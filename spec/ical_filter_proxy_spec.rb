require 'spec_helper'

RSpec.describe IcalFilterProxy do
  describe '.config_file_path' do
    it { expect(described_class.config_file_path).to eq(File.expand_path('../config.yml', __dir__)) }
  end

  describe '.config' do
    before do
      expect(IcalFilterProxy).to receive(:config_file_path).and_return File.expand_path('../config.yml.example', __dir__)
    end

    it 'parses the YAML file at config_file_path' do
      expect(described_class.config).to eq example_config
    end
  end

  describe '.calendars' do
    before do
      expect(IcalFilterProxy).to receive(:config).and_return(example_config)
    end

    let(:calendars) { described_class.calendars }

    it "builds a hash" do
      expect(calendars).to be_a(Hash)
    end

    it "has an entry for each calendar in the config file" do
      expect(calendars).to have_key('rota')
    end

    it 'creates a Calenar object for each entry' do
      expect(calendars['rota']).to be_a(IcalFilterProxy::Calendar)
    end

    it 'adds ical_url to the Calendar object' do
      expect(calendars['rota'].ical_url).to eq('https://url-to-calendar.ical')
    end

    it 'adds api_key to the Calenar object' do
      expect(calendars['rota'].api_key).to eq('abc12')
    end

    it 'adds filters to the Calendar object' do
      filter_rule = calendars['rota'].filter_rules.first

      expect(filter_rule).to be_a(IcalFilterProxy::FilterRule)
      expect(filter_rule.field).to eq('start_time')
      expect(filter_rule.operator).to eq('equals')
      expect(filter_rule.values).to eq('09:00')
    end
  end

  def example_config
    {
      'rota' => {
        'ical_url' => 'https://url-to-calendar.ical',
        'api_key' => 'abc12',
        'rules' => [
          { 'field' => 'start_time', 'operator' => 'equals', 'val' => '09:00' }
        ]
      }
    }
  end


end
