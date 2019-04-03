# frozen_string_literal: true

require 'notifications'

class JobCreatorConsumer < Racecar::Consumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    message_value = kafka_message.value
    Rails.logger.debug("Received message: #{message_value}")

    DispatchMessageJob.perform_later(message_value)
  end
end
