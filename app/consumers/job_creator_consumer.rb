# frozen_string_literal: true

require 'notifications'

class JobCreatorConsumer < ApplicationConsumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    with_metrics do
      message_value = kafka_message.value
      Rails.logger.debug("Received message: #{message_value}")

      DispatchMessageJob.perform_later(message_value)
    end
  end
end
