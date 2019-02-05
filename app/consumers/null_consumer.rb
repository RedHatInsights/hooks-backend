# frozen_string_literal: true

require 'notifications'

class NullConsumer < Racecar::Consumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    Rails.logger.info("Discarded message: #{kafka_message.value}")
  end
end
