# frozen_string_literal: true

# Sends a simple one-step notification.
class SendNotificationJob < ApplicationJob
  def perform(endpoint, timestamp, category, message)
    Rails.logger.debug("Received a job to send: #{endpoint}, #{timestamp}, #{category}, #{message}")

    endpoint.send_message(timestamp: timestamp, category: category, message: message)

    Rails.logger.debug("Job successfully sent: #{endpoint}, #{timestamp}, #{category}, #{message}")
  end
end
