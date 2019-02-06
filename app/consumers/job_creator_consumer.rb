# frozen_string_literal: true

require 'notifications'
require 'dispatcher'

class JobCreatorConsumer < Racecar::Consumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    message_value = kafka_message.value
    Rails.logger.debug("Received message: #{message_value}")

    message = Message.from_json(message_value)

    dispatcher = Dispatcher.new(message)
    dispatcher.dispatch!
  end
end
