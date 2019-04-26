# frozen_string_literal: true

require 'test_helper'
require 'dispatcher'

class DispatcherTest < ActiveSupport::TestCase
  let(:endpoint) { FactoryBot.create(:endpoint, :with_account) }
  let(:filter) { FactoryBot.create(:filter, endpoint: endpoint, account: endpoint.account) }
  let(:msg) do
    Message.new(
      account_id: endpoint.account_id,
      application: 'app',
      event_type: 'something',
      level: 'low',
      message: 'something',
      timestamp: Time.now.to_s
    )
  end
  let(:dispatcher) { ::Dispatcher.new(msg) }

  it 'dispatches messages to the right endpoints' do
    filter
    job_class = mock
    dispatcher.expects(:job_class).returns(job_class).twice
    job_class.expects(:perform_later).with(endpoint, msg.timestamp, msg.level, msg.message)
    dispatcher.dispatch!
  end
end
