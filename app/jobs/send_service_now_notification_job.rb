# frozen_string_literal: true

class SendServiceNowNotificationJob < SendNotificationJob
  queue_as :unsorted_notifications

  def perform(endpoint, timestamp, category, message)
    super
  end
end
