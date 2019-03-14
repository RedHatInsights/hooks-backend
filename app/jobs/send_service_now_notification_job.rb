# frozen_string_literal: true

class SendServiceNowNotificationJob < SendNotificationJob
  queue_as :unsorted_notifications

  def perform(endpoint, timestamp, level, message)
    super
  end
end
