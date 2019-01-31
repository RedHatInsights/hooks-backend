# frozen_string_literal: true

# Will be responsible for dispatching messages according to user-set filters
class Dispatcher
  def initialize(message)
    @message = message
  end

  def dispatch!
    job_class.perform_later(endpoint, timestamp, category, message)
  end

  private

  def job_class
    SendServiceNowNotificationJob
  end

  def endpoint
    nil
  end

  def timestamp
    @message.timestamp
  end

  def category
    @message.severity
  end

  def message
    @message.message
  end
end
