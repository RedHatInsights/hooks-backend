# frozen_string_literal: true
require 'test_helper'

class AppTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:app)
  end

  should validate_uniqueness_of :name
  should validate_presence_of :name

  should have_many(:event_types).dependent(:destroy)
end
