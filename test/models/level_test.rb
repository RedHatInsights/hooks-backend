# frozen_string_literal: true

require 'test_helper'

class LevelTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:level, :with_event_type)
  end

  should belong_to(:event_type)
  should validate_presence_of(:title)
  should validate_presence_of(:external_id)
  should validate_uniqueness_of(:external_id).scoped_to(:event_type_id)

  should have_many :level_filters
  should have_many(:filters).through(:level_filters)
end
