# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  def perform(endpoint, timestamp, category, message)
    Rails.logger.debug("Simulated servicenow call. #{endpoint}, #{timestamp}, #{category}, #{message}")
  end
end
