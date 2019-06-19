# frozen_string_literal: true

require 'net/http'
require 'uri'

module Endpoints
  class HttpEndpoint < Endpoint
    def send_message(timestamp:, level:, message:, event_type:, application:)
      payload = to_payload(timestamp: timestamp, message: message,
                           application: application, event_type: event_type, level: level)
      response = nil

      http_request do |connection|
        request = generate_post(payload)
        response = connection.request request
      end

      validate_response(response)
    rescue Timeout::Error => e
      raise Notifications::RecoverableError, e
    end

    protected

    def address
      URI(url)
    end

    def to_payload(timestamp:, level:, message:, event_type:, application:)
      {
        timestamp: timestamp,
        application: application,
        event_type: event_type,
        level: level,
        message: message
      }.to_json
    end

    def http_request
      Net::HTTP.start(
        address.host,
        address.port
      ) do |connection|
        yield(connection)
      end
    end

    def generate_post(payload)
      request = Net::HTTP::Post.new(address)
      request.content_type = 'application/json'
      request.body = payload
      request
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
