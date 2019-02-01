# frozen_string_literal: true

class FilterTest < ActiveSupport::TestCase
  should have_many :endpoint_filters
  should have_many(:endpoints).through(:endpoint_filters)

  should have_many :severity_filters

  should have_many :app_filters
  should have_many(:apps).through(:app_filters)

  should have_many(:event_type_filters)
  should have_many(:event_types).through(:event_type_filters)

  should belong_to(:account)

  before do
    Builder::App.build! do |a|
      a.name 'not_useful'
      event_types.each { |type| a.event_type type }
    end
  end

  let(:account) { FactoryBot.create(:account) }
  let(:msg) do
    Message.new :application => app.name, :event_type => app.event_types.first.name,
                :severity => 'critical', :account_id => account.id, :timestamp => Time.zone.now,
                :message => 'hello'
  end
  let(:event_types) { %w[something something-else yet-something-else] }
  let(:app_name) { 'filter-test-app-1' }
  let(:app) do
    Builder::App.build! do |a|
      a.name app_name
      event_types.each { |type| a.event_type type }
    end
  end

  it 'allows matching by application name, event type and severity' do
    Builder::Filter.build!(account) do |b|
      b.application(app.name, app.event_types.first.name)
      b.severity 'low'
    end

    filter = Builder::Filter.build!(account) do |b|
      b.application app.name, app.event_types.first.name
      b.severities 'critical', 'high'
    end

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:severity => 'missing')).must_equal []
  end

  it 'allows matching by application name, event type and severity wildcard' do
    filter = Builder::Filter.build!(account) do |b|
      b.application app.name, app.event_types.first.name
      b.severity.any!
    end

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:severity => 'missing')).must_equal [filter]
  end

  it 'allows matching by application name, event type wildcard and severity wildcard' do
    filter = Builder::Filter.build!(account) do |b|
      b.application(app.name).event_type.any!
      b.severity.any!
    end

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal []
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal [filter]
    Filter.matching_message(msg.merge(:severity => 'missing')).must_equal [filter]
  end

  it 'allows matching by application name wildcard, event type wildcard and severity' do
    filter = Builder::Filter.build!(account) do |b|
      b.application.any!
       .event_type.any!
      b.severities 'critical', 'high'
    end

    Filter.matching_message(msg).must_equal [filter]
    Filter.matching_message(msg.merge(:application => 'missing')).must_equal [filter]
    Filter.matching_message(msg.merge(:event_type => 'missing')).must_equal [filter]
    Filter.matching_message(msg.merge(:severity => 'missing')).must_equal []
  end

  it 'does not allow matching by disabled filters' do
    filter = Builder::Filter.build!(account) do |b|
      b.application do |a|
        a.any!
        a.event_type.any!
      end
    end

    Filter.matching_message(msg).must_equal [filter]

    filter.enabled = false
    filter.save!

    Filter.matching_message(msg).must_equal []
  end
end

class SeverityFilterTest < ActiveSupport::TestCase
  should belong_to(:filter)
end
