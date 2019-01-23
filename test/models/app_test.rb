require 'test_helper'

class AppTest < ActiveSupport::TestCase
  should validate_uniqueness_of :name
  should validate_presence_of :name
end
