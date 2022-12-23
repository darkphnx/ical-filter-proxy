require 'spec_helper'

RSpec.describe IcalFilterProxy do
  describe '.config_file_path' do
    it { expect(described_class.config_file_path).to eq(File.expand_path('../config.yml', __dir__)) }
  end

  describe '.config' do
    before do
      ENV['ICAL_FILTER_PROXY_API_KEY'] = "abc12"
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

    it "has an entry for each calendar in the config file" do
      expect(calendars).to have_key('rota')
    end

    it 'calls CalendarBuilder#build for each entry and stores the return' do
      calendar_builder = instance_double(IcalFilterProxy::CalendarBuilder)
      expect(IcalFilterProxy::CalendarBuilder)
        .to receive(:new)
        .with(example_config['rota'])
        .and_return(calendar_builder)

      calendar = instance_double(IcalFilterProxy::CalendarBuilder)
      expect(calendar_builder)
        .to receive(:build)
        .and_return(calendar)

      expect(calendars['rota']).to eq(calendar)
    end
  end

  def example_config
    {
      'rota' => {
        'ical_url' => 'https://url-to-calendar.ical',
        'api_key' => 'abc12',
        'rules' => [
          { 'field' => 'start_time', 'operator' => 'equals', 'val' => '09:00' }
        ],
        'alarms' => {
          'clear_existing' => true,
          'triggers'=> [ '-P1DT0H0M0S', '-P1DT1H1M2S' ]
        }
      }
    }
  end

end
