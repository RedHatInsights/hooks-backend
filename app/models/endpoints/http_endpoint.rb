# frozen_string_literal: true

require 'net/http'
require 'uri'

module Endpoints
  class HttpEndpoint < Endpoint
    def send_message(timestamp:, level:, message:)
      payload = to_payload(timestamp: timestamp, level: level, message: message)
      response = Net::HTTP.post(
        address,
        payload,
        'Content-Type' => 'application/json'
      )
      validate_response(response)
    rescue Timeout::Error => ex
      raise Notifications::RecoverableError, ex
    end

    protected

    def address
      URI(url)
    end

    def to_payload(timestamp:, level:, message:)
      {
        timestamp: timestamp,
        level: level,
        message: message
      }.to_json
    end

    private

    def validate_response(response)
      case response
      when Net::HTTPClientError
        raise Notifications::FatalError, "Got client error: #{response}"
      when Net::HTTPServerError
        raise Notifications::RecoverableError, "Got server error: #{response}"
      end
    end
  end
end
