# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:account)
  end
  should have_many :users
  should have_many :endpoints
  should have_many :filters
  should validate_uniqueness_of(:account_number).case_insensitive
  should validate_presence_of(:account_number)
end
