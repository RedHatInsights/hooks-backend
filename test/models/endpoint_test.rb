# frozen_string_literal: true

require 'test_helper'

class EndpointTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:endpoint, :with_account)
  end

  should validate_presence_of(:name)
  should validate_presence_of(:url)
  should belong_to :account
end
