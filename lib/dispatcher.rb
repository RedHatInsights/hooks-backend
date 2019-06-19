# frozen_string_literal: true

# Will be responsible for dispatching messages according to user-set filters
class Dispatcher
  def initialize(message)
    @message = message
  end

  # rubocop:disable Metrics/AbcSize
  def dispatch!
    Rails.logger.info("Dispatching: #{@message.to_h}")

    endpoints.each do |endpoint|
      job_class.perform_later(endpoint, timestamp, application, event_type, level, message)
      Rails.logger.info("Enqueued #{job_class} with endpoint: #{endpoint.id}")
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def endpoints
    relevant_filters = Filter.matching_message(@message).preload(:endpoint)
    endpoints = relevant_filters.map(&:endpoint).flatten.uniq
    Rails.logger.info("Found #{endpoints.length} endpoints to send messages to.")
    endpoints
  end

  def job_class
    SendNotificationJob
  end

  def timestamp
    @message.timestamp
  end

  def level
    @message.level
  end

  def message
    @message.message
  end

  def event_type
    @message.event_type
  end

  def application
    @message.application
  end
end
