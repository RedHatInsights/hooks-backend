# frozen_string_literal: true

require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  should belong_to(:endpoint)
  should validate_presence_of(:endpoint)

  should have_many :level_filters
  should have_many(:levels).through(:level_filters)

  should have_many :app_filters
  should have_many(:apps).through(:app_filters)

  should have_many(:event_type_filters)
  should have_many(:event_types).through(:event_type_filters)

  should belong_to(:account)

  before do
    Builder::App.build! do |a|
      a.name 'not_useful'
      event_types.each { |type| a.event_type(type).levels(levels) }
    end
  end

  let(:account) { FactoryBot.create(:account) }
  let(:msg) do
    Message.new :application => app.name, :event_type => app.event_types.first.external_id,
                :level => 'critical', :account_id => account.account_number,
                :timestamp => Time.zone.now, :message => 'hello'
  end
  let(:event_types) { %w[something something-else yet-something-else] }
  let(:levels) { %w[low medium high critical] }
  let(:app_name) { 'filter-test-app-1' }
  let(:app) do
    Builder::App.build! do |a|
      a.name app_name
      event_types.each { |type| a.event_type(type).levels(levels) }
    end
  end
  let(:endpoint) do
    FactoryBot.create(:endpoint, account: account)
  end

  it 'allows matching by application name, event type and level' do
    FactoryBot.create(
      :filter,
      account: account,
      endpoint: endpoint,
      apps: [app],
      event_types: [app.event_types.first],
      levels: [app.event_types.first.levels.where(:external_id => 'low').first]
    )

    filter = FactoryBot.create(
      :filter,
      account: account,
      endpoint: endpoint,
      apps: [app],
      event_types: [app.event_types.first],
      levels: app.event_types.first.levels.where(external_id: %w[critical high])
    )

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:level => 'missing')).must_equal []
  end

  it 'allows matching by application name, event type and level wildcard' do
    filter = FactoryBot.create(
      :filter,
      account: account,
      endpoint: endpoint,
      apps: [app],
      event_types: [app.event_types.first]
    )

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:level => 'missing')).must_equal [filter]
  end

  it 'allows matching by application name, event type wildcard and level wildcard' do
    filter = FactoryBot.create(
      :filter,
      account: account,
      endpoint: endpoint,
      apps: [app]
    )

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal [filter]
    Filter.matching_message(msg.merge(:level => 'missing')).must_equal [filter]
  end

  it 'does not allow matching by disabled filters' do
    filter = FactoryBot.create(
      :filter,
      account: account,
      endpoint: endpoint
    )

    Filter.matching_message(msg).must_equal [filter]

    filter.enabled = false
    filter.save!

    Filter.matching_message(msg).must_equal []
  end
end

class LevelFilterTest < ActiveSupport::TestCase
  should belong_to(:filter)
end
