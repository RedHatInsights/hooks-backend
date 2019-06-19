# frozen_string_literal: true

require 'test_helper'
require 'notifications'

class SendNotificationJobTest < ActiveJob::TestCase
  let(:endpoint) { FactoryBot.create(:endpoint, :with_account) }
  let(:timestamp) { Time.current.to_s }
  let(:level) { 'test_level' }
  let(:application) { 'test_application' }
  let(:event_type) { 'test_event_type' }
  let(:message_text) { 'testing 1,2,3' }

  it 'Performs the job once on success' do
    # endpoint will be serialized, need to set expectation on the deserialized object
    Endpoint.any_instance.expects(:send_message).returns(nil)
    expected_time = DateTime.current
    DateTime.expects(:current).returns(expected_time)

    assert_performed_jobs(1) do
      SendNotificationJob.perform_later(endpoint, timestamp, application, event_type, level, message_text)
    end

    endpoint.reload
    assert_equal Endpoint::STATUS_SUCCESS, endpoint.last_delivery_status
    assert_equal expected_time.to_i, endpoint.last_delivery_time.to_i
  end

  it 'Retries the job 3 times on RecoverableError' do
    assert_equal true, endpoint.active
    Endpoint.any_instance.expects(:send_message).raises(::Notifications::RecoverableError, 'test').times(3)
    expected_time = DateTime.current
    DateTime.expects(:current).times(3).returns(expected_time)
            .then.returns(expected_time + 1.second)
            .then.returns(expected_time + 2.seconds)

    assert_performed_jobs(3) do
      SendNotificationJob.perform_later(endpoint, timestamp, application, event_type, level, message_text)
    end

    endpoint.reload

    assert_equal false, endpoint.active
    assert_equal Endpoint::STATUS_FAILURE, endpoint.last_delivery_status
    assert_equal (expected_time + 2.seconds).to_i, endpoint.last_delivery_time.to_i
    assert_equal expected_time.to_i, endpoint.first_failure_time.to_i
  end

  it 'Fails the job and disables the endpoint immediately on FatalError' do
    assert_equal true, endpoint.active
    Endpoint.any_instance.expects(:send_message).raises(Notifications::FatalError, 'test')
    expected_time = DateTime.current
    DateTime.expects(:current).returns(expected_time)

    assert_performed_jobs(1) do
      SendNotificationJob.perform_later(endpoint, timestamp, application, event_type, level, message_text)
    end

    endpoint.reload

    assert_equal false, endpoint.active
    assert_equal Endpoint::STATUS_FAILURE, endpoint.last_delivery_status
    assert_equal expected_time.to_i, endpoint.last_delivery_time.to_i
    assert_equal expected_time.to_i, endpoint.first_failure_time.to_i
  end
end
