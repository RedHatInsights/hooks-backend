# frozen_string_literal: true

require 'test_helper'

class EndpointTest < ActiveSupport::TestCase
  def setup
    endpoint = FactoryBot.create(:endpoint, :with_account)
    FactoryBot.create(:filter, endpoint: endpoint, account: endpoint.account)
  end

  should have_one(:filter)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).scoped_to(:account_id)
  should validate_presence_of(:url)
  should belong_to :account
end
