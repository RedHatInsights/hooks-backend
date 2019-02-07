# frozen_string_literal: true

class LoggerEndpointController < ActionController::API
  def create
    Rails.logger.info("A message was received: #{params}")
  end
end
