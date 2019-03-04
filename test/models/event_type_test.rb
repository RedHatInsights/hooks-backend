# frozen_string_literal: true

require 'test_helper'

class EventTypeTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:event_type, :with_app)
  end

  should belong_to(:app)
  should have_many(:event_type_filters)
  should have_many(:filters).through(:event_type_filters)

  should have_many(:levels)

  should validate_presence_of(:external_id)
  should validate_uniqueness_of(:external_id).scoped_to(:app_id)
  should validate_presence_of(:title)
end
