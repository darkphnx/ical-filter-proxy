require 'spec_helper'

RSpec.describe IcalProxy::Transformer::LocationRules do
  let(:event) { Icalendar::Event.new }

  def rule_obj(pattern:, search_in: ['summary'], set_location: nil, geo: nil, extract_from: nil, capture_group: nil, set_if_blank: nil)
    IcalProxy::Transformer::LocationRules::Rule.new(
      pattern,
      search_in,
      set_location,
      geo,
      extract_from,
      capture_group,
      set_if_blank
    )
  end

  it 'sets GEO when pattern matches summary or description' do
    event.summary = 'Away match vs Watford FC'
    latlon = { 'lat' => 51.6565, 'lon' => -0.3903 }

    rules = [rule_obj(pattern: /Watford/i, search_in: ['summary', 'description'], geo: latlon)]
    described_class.new(rules).apply(event)

    expect(event.geo).not_to be_nil
    expect(event.geo).to eq [51.6565,-0.3903]
    expect(event.location).to be_nil
  end

  it 'sets location to a fixed value when pattern matches description' do
    event.description = 'Training in Hemel this week'

    rules = [rule_obj(pattern: /hemel/i, search_in: ['description'], set_location: 'HP1 2AA')]
    described_class.new(rules).apply(event)

    expect(event.location).to eq('HP1 2AA')
  end

  it 'extracts location from description using capture group when location blank' do
    event.description = "Location: Hall A\nBring water"

    rules = [rule_obj(pattern: /Location:\s*([^\n]+)/i, extract_from: 'description', capture_group: 1, set_if_blank: true)]
    described_class.new(rules).apply(event)

    expect(event.location).to eq('Hall A')
  end

  it 'does not override existing location when set_if_blank is true' do
    event.location = 'Existing'
    event.description = 'Location: New Place'

    rules = [rule_obj(pattern: /Location:\s*([^\n]+)/i, extract_from: 'description', set_if_blank: true)]
    described_class.new(rules).apply(event)

    expect(event.location).to eq('Existing')
  end

  it 'overrides existing location when set_if_blank is false' do
    event.location = 'Existing'
    event.description = 'Location: New Place'

    rules = [rule_obj(pattern: /Location:\s*([^\n]+)/i, extract_from: 'description', set_if_blank: false)]
    described_class.new(rules).apply(event)

    expect(event.location).to eq('New Place')
  end
end

