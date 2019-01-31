# frozen_string_literal: true
require 'lib/notifications'
require 'lib/dispatcher'

class JobCreatorConsumer < Racecar::Consumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    message = Message.from_json(kafka_message.value)

    dispatcher = Dispatcher.new(message)
    dispatcher.dispatch!
  end
end
