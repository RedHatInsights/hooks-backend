# frozen_string_literal: true

require 'net/http'
require 'uri'

module Endpoints
  class HttpEndpoint < Endpoint
    def send_message(timestamp:, category:, message:)
      payload = to_payload(timestamp: timestamp, category: category, message: message)
      Net::HTTP.post(
        address,
        payload,
        'Content-Type' => 'application/json'
      )
    end

    protected

    def address
      URI(url)
    end

    def to_payload(timestamp:, category:, message:)
      {
        timestamp: timestamp,
        category: category,
        message: message
      }.to_json
    end
  end
end
