require 'spec_helper'

RSpec.describe IcalProxy::Transformer::Rename do
  let(:event) { Icalendar::Event.new }

  it 'replaces matching text in summary (string pattern)' do
    event.summary = 'Project Draft plan'

    transformer = described_class.new('Draft', 'Final')
    transformer.apply(event)

    expect(event.summary).to eq('Project Final plan')
  end

  it 'normalizes summary when description matches (regex, set_on_match)' do
    event.summary = 'Yoga session'
    event.description = 'Join us at Spin Class tonight'

    transformer = described_class.new(/spin( class)?/i, 'Spin', search_in: ['summary', 'description'], set_on_match: true)
    transformer.apply(event)

    expect(event.summary).to eq('Spin')
  end

  it 'does nothing when no field matches' do
    event.summary = 'Weekly Meeting'
    event.description = 'General catch up'

    transformer = described_class.new(/does not match/i, 'New', search_in: ['summary', 'description'])
    transformer.apply(event)

    expect(event.summary).to eq('Weekly Meeting')
  end
end

