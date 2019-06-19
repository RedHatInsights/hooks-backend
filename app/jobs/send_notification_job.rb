# frozen_string_literal: true

require 'notifications'

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

  around_perform :handle_log
  around_perform :handle_stats

  # rubocop:disable Metrics/ParameterLists
  def perform(endpoint, timestamp, application, event_type, level, message)
    unless endpoint.active
      Rails.logger.debug("Endpoint #{endpoint} is not active, discarding message")
      return
    end

    endpoint.send_message(timestamp: timestamp, message: message,
                          application: application, event_type: event_type, level: level)
  end
  # rubocop:enable Metrics/ParameterLists

  def endpoint
    arguments.first
  end

  private

  def handle_log
    Rails.logger.debug("Received a job to send with arguments: #{arguments}")

    yield

    Rails.logger.debug("Job successfully sent, arguments: #{arguments}")
  end

  def handle_stats
    action_timestamp = DateTime.current
    status = Endpoint::STATUS_SUCCESS
    yield
  rescue RuntimeError => e
    status = Endpoint::STATUS_FAILURE
    raise e
  ensure
    update_endpoint_stats(status, action_timestamp)
  end

  def update_endpoint_stats(status, action_timestamp)
    # update failure timestamp, if it's the first failure
    if status == 'failure'
      Endpoint.where(id: endpoint.id, last_delivery_status: ['success', nil])
              .where('last_delivery_time <= ? or last_delivery_time is null', action_timestamp)
              .update(first_failure_time: action_timestamp)
    end
    # update delivery status only if we are the latest attempt
    Endpoint.where(id: endpoint.id)
            .where('last_delivery_time <= ? or last_delivery_time is null', action_timestamp)
            .update(last_delivery_status: status, last_delivery_time: action_timestamp)
  end
end
