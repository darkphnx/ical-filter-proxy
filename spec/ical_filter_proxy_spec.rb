require 'spec_helper'

RSpec.describe IcalFilterProxy do
  describe '.start_rack_app' do
    let(:rack_app) { IcalFilterProxy.start_rack_app }

    before do
      example_config_file_path = File.expand_path('../config.yml.example', __dir__)
      example_config = YAML.safe_load(File.read(example_config_file_path))
      expect(IcalFilterProxy).to receive(:config).and_return(example_config)
    end

    it "initializes a RackApp with filters from config" do
      expect(rack_app.filters['rota']).to have_key(:calendar)
    end

    it "sets up a filters hash that defaults to nil" do
      expect(rack_app.filters['foo']).to be_nil
    end
  end
end
