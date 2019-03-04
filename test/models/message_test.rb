# frozen_string_literal: true

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'basic properties' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      level: 'level',
      timestamp: 'timestamp',
      message: 'message',
      account_id: 'uuid'
    }

    message = Message.new(properties)

    assert_equal 'application', message.application
    assert_equal 'event_type', message.event_type
    assert_equal 'level', message.level
    assert_equal 'timestamp', message.timestamp
    assert_equal 'message', message.message
    assert_equal 'uuid', message.account_id
  end

  test 'from_json' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      level: 'level',
      timestamp: 'timestamp',
      message: 'message',
      account_id: 'uuid'
    }.to_json

    message = Message.from_json(properties)

    assert_equal 'application', message.application
    assert_equal 'event_type', message.event_type
    assert_equal 'level', message.level
    assert_equal 'timestamp', message.timestamp
    assert_equal 'message', message.message
    assert_equal 'uuid', message.account_id
  end

  test 'to_h' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      level: 'level',
      timestamp: 'timestamp',
      message: 'message',
      account_id: 'uuid'
    }
    message = Message.new(properties)

    assert_equal properties, message.to_h
  end

  test 'merge' do
    properties = {
      application: 'application',
      event_type: 'event_type',
      level: 'level',
      timestamp: 'timestamp',
      message: 'message',
      account_id: 'uuid'
    }
    message = Message.new(properties)

    properties.each do |key, _value|
      assert_equal properties.merge(key => 'custom_value'), message.merge(key => 'custom_value').to_h
    end
  end
end
