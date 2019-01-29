# frozen_string_literal: true
class FilterTest < ActiveSupport::TestCase
  should have_many :endpoint_filters
  should have_many(:endpoints).through(:endpoint_filters)
  should have_many(:accounts).through(:endpoints)

  should have_many :severity_filters

  should have_many :app_filters
  should have_many(:apps).through(:app_filters)

  should have_many(:event_type_filters)
  should have_many(:event_types).through(:event_type_filters)

  before do
    Builder::App.build! do |a|
      a.name 'not_useful'
      event_types.each { |type| a.event_type type }
    end
  end

  let(:msg) do
    { :application => app.name, :type => app.event_types.first.name, :severity => 'critical' }
  end
  let(:event_types) { %w(something something-else yet-something-else) }
  let(:app_name) { 'filter-test-app-1' }
  let(:app) do
    Builder::App.build! do |a|
      a.name app_name
      event_types.each { |type| a.event_type type }
    end
  end

  it 'allows matching by application name, event type and severity' do
    Builder::Filter.build! do |b|
      b.application(app.name, app.event_types.first.name)
      b.severity 'low'
    end

    filter = Builder::Filter.build! do |b|
      b.application app.name, app.event_types.first.name
      b.severities 'critical', 'high'
    end

    Filter.matching_message(msg).must_equal [filter]
  end

  it 'allows matching by application name, event type and severity wildcard' do
    filter = Builder::Filter.build! do |b|
      b.application app.name, app.event_types.first.name
      b.severity.any!
    end

    Filter.matching_message(msg).must_equal [filter]
  end

  it 'allows matching by application name, event type wildcard and severity wildcard' do
    filter = Builder::Filter.build! do |b|
      b.application(app.name).event_type.any!
      b.severities 'critical', 'high'
    end

    Filter.matching_message(msg).must_equal [filter]
  end

  it 'allows matching by application name wildcard, event type wildcard and severity' do
    filter = Builder::Filter.build! do |b|
      b.application.any!
      b.severities 'critical', 'high'
    end

    Filter.matching_message(msg).must_equal [filter]
  end
end

class SeverityFilterTest < ActiveSupport::TestCase
  should belong_to(:filter)
end
