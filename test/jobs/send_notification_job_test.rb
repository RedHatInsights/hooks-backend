# frozen_string_literal: true

require 'test_helper'

class SendNotificationJobTest < ActiveJob::TestCase
  let(:endpoint) { FactoryBot.create(:endpoint, :with_account) }
  let(:timestamp) { Time.current.to_s }
  let(:level) { 'test_level' }
  let(:message_text) { 'testing 1,2,3' }

  it 'Performs the job once on success' do
    # endpoint will be serialized, need to set expectation on the deserialized object
    Endpoint.any_instance.expects(:send_message).returns(nil)

    assert_performed_jobs(1) do
      SendNotificationJob.perform_later(endpoint, timestamp, level, message_text)
    end
  end

  it 'Retries the job 3 times on RecoverableError' do
    assert_equal true, endpoint.active
    Endpoint.any_instance.expects(:send_message).raises(Notifications::RecoverableError, 'test').times(3)

    assert_performed_jobs(3) do
      SendNotificationJob.perform_later(endpoint, timestamp, level, message_text)
    end

    endpoint.reload

    assert_equal false, endpoint.active
  end

  it 'Fails the job and disables the endpoint immediately on FatalError' do
    assert_equal true, endpoint.active
    Endpoint.any_instance.expects(:send_message).raises(Notifications::FatalError, 'test')

    assert_performed_jobs(1) do
      SendNotificationJob.perform_later(endpoint, timestamp, level, message_text)
    end

    endpoint.reload

    assert_equal false, endpoint.active
  end
end
