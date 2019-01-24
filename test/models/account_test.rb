# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:account)
  end
  should have_many :users
  should have_many :endpoints
end
