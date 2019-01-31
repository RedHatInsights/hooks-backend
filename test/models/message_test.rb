# frozen_string_literal: true
require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'basic properties' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      severity: 'severity',
      timestamp: 'timestamp',
      message: 'message'
    }

    message = Message.new(properties)

    assert_equal 'application', message.application
    assert_equal 'event_type', message.event_type
    assert_equal 'severity', message.severity
    assert_equal 'timestamp', message.timestamp
    assert_equal 'message', message.message
  end

  test 'from_json' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      severity: 'severity',
      timestamp: 'timestamp',
      message: 'message'
    }.to_json

    message = Message.from_json(properties)

    assert_equal 'application', message.application
    assert_equal 'event_type', message.event_type
    assert_equal 'severity', message.severity
    assert_equal 'timestamp', message.timestamp
    assert_equal 'message', message.message
  end
end
