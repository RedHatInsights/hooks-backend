# frozen_string_literal: true

# Will be responsible for dispatching messages according to user-set filters
class Dispatcher
  def initialize(message)
    @message = message
  end

  def dispatch!
    Rails.logger.info("Dispatching: #{@message.to_h}")

    endpoints.each do |endpoint|
      job_class.perform_later(endpoint, timestamp, level, message)
      Rails.logger.info("Enqueued #{jobclass} with endpoint: #{endpoint.id}")
    end
  end

  private

  def endpoints
    relevant_filters = Filter.matching_message(@message).preload(:endpoints)
    endpoints = relevant_filters.map(&:endpoints).flatten.uniq
    Rails.logger.info("Found #{endpoints.length} endpoints to send messages to.")
    endpoints
  end

  def job_class
    SendServiceNowNotificationJob
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
end
