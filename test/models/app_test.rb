# frozen_string_literal: true

require 'test_helper'

class AppTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:app)
  end

  should validate_uniqueness_of :name
  should validate_presence_of :name

  should have_many(:event_types).dependent(:destroy)

  should have_many(:app_filters)
  should have_many(:filters).through(:app_filters)
end

class AppBuilderTest < ActiveSupport::TestCase
  let(:app_name) { 'app-builder-test' }

  it 'builds an application' do
    app = Builder::App.build! do |b|
      b.name app_name
    end
    app.must_be :valid?
    app.wont_be :new_record?
    app.name.must_equal app_name
  end

  it 'build an application with event types' do
    event_types = %w[something something-else yet-something-else]
    app = Builder::App.build! do |b|
      b.name name
      event_types.each { |type| b.event_type type }
    end
    app.name.must_equal name
    app.event_types.map(&:valid?).must_equal [true].cycle(3).to_a
    app.event_types.map(&:new_record?).must_equal [false].cycle(3).to_a
    app.event_types.map(&:name).sort.must_equal event_types.sort
  end
end
