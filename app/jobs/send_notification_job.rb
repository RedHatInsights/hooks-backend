# frozen_string_literal: true

# Sends a simple one-step notification.
class SendNotificationJob < ApplicationJob
  def self.disable_endpoint(endpoint)
    endpoint.active = false
    endpoint.save!
  end

  discard_on(Notifications::FatalError) do |job, error|
    endpoint = job.endpoint
    disable_endpoint(endpoint)
    Rails.logger.warn("Disabled #{endpoint} after receiving #{error.inspect}")
  end

  retry_on(Notifications::RecoverableError, wait: :exponentially_longer, attempts: 3) do |job, error|
    endpoint = job.endpoint
    disable_endpoint(endpoint)
    Rails.logger.warn("Disabled #{endpoint} after too many retries for #{error.inspect}")
  end

  def perform(endpoint, timestamp, category, message)
    Rails.logger.debug("Received a job to send: #{endpoint}, #{timestamp}, #{category}, #{message}")

    unless endpoint.active
      Rails.logger.debug("Endpoint #{endpoint} is not active, discarding message")
      return
    end

    endpoint.send_message(timestamp: timestamp, category: category, message: message)

    Rails.logger.debug("Job successfully sent: #{endpoint}, #{timestamp}, #{category}, #{message}")
  end

  def endpoint
    arguments.first
  end
end
