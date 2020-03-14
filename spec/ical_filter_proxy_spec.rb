require 'spec_helper'

RSpec.describe IcalFilterProxy do
  describe '.start_rack_app' do
    let(:rack_app) { IcalFilterProxy.start_rack_app }
    let(:filters) do
      {
        'rota' => instance_double(IcalFilterProxy::Calendar)
      }
    end

    before do
      expect(IcalFilterProxy).to receive(:filters).and_return filters
    end

    it "initializes a RackApp with filters from config" do
      expect(rack_app.filters).to eq(filters)
    end
  end

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

  describe '.filters' do
    before do
      expect(IcalFilterProxy).to receive(:config).and_return(example_config)
    end

    let(:filters) { described_class.filters }

    it "builds a hash" do
      expect(filters).to be_a(Hash)
    end

    it "has an entry for each calendar in the config file" do
      expect(filters).to have_key('rota')
    end

    it 'creates a Calenar object for each entry' do
      expect(filters['rota']).to be_a(IcalFilterProxy::Calendar)
    end

    it 'adds ical_url to the Calendar object' do
      expect(filters['rota'].ical_url).to eq('https://url-to-calendar.ical')
    end

    it 'adds api_key to the Calenar object' do
      expect(filters['rota'].api_key).to eq('abc12')
    end

    it 'adds filters to the Calendar object' do
      filter_rule = filters['rota'].filter_rules.first

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
