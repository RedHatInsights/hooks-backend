require 'test_helper'

class EventTypeTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:event_type, :with_app)
  end

  should belong_to(:app)
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).scoped_to(:app_id)
end
