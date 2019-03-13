# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class HttpEndpointTest < ActiveSupport::TestCase
  let(:url) { 'http://httpendpointtest.com' }
  let(:endpoint) do
    FactoryBot.create(:http_endpoint, :with_account, url: url)
  end
  let(:timestamp) { Time.current.to_s }
  let(:level) { 'test_level' }
  let(:message_text) { 'testing 1,2,3' }
  let(:expect_request) do
    stub_request(:post, url).with(
      body: {
        timestamp: timestamp,
        level: level,
        message: message_text
      }
    )
  end

  it 'POSTs successfully' do
    expect_request

    endpoint.send_message(timestamp: timestamp, level: level, message: message_text)
  end

  it 'recovers from timeout' do
    expect_request.to_timeout

    assert_raises Notifications::RecoverableError do
      endpoint.send_message(timestamp: timestamp, level: level, message: message_text)
    end
  end

  it 'recovers from 5xx response' do
    expect_request.to_return(status: 501)

    assert_raises Notifications::RecoverableError do
      endpoint.send_message(timestamp: timestamp, level: level, message: message_text)
    end
  end

  it 'Fails for 4xx response' do
    expect_request.to_return(status: 404)

    assert_raises Notifications::FatalError do
      endpoint.send_message(timestamp: timestamp, level: level, message: message_text)
    end
  end
end
