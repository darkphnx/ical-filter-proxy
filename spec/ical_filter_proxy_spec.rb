require 'spec_helper'

RSpec.describe IcalFilterProxy do
  describe '.start' do
    let(:web_app) { IcalFilterProxy.start }

    before do
      example_config_file_path = File.expand_path('../../config.yml.example', __FILE__)
      example_config = YAML.load(open(example_config_file_path))
      expect(IcalFilterProxy).to receive(:config).and_return(example_config)
    end

    it "initializes a WebApp with filters from config" do
      expect(web_app.filters['rota']).to have_key(:calendar)
    end

    it "sets up a filters hash that defaults to nil" do
      expect(web_app.filters['foo']).to be_nil
    end
  end
end
