# frozen_string_literal: true

# model class for messages that were enqueued for notifications.
# for now we can get away with pure Ruby object, but if we need, it can become
# an ActiveModel.
# This class will serve as our de-facto interface with other applications.
class Message
  def self.from_json(message_json)
    hash = JSON.parse(message_json)
    hash.symbolize_keys!

    # will throw "ArgumentError: unknown keyword" exceptions for unknown keys.
    # will need proper wrapping.
    new(hash)
  end

  attr_reader :application, :event_type, :severity, :timestamp, :message

  def initialize(application:, event_type:, severity:, timestamp:, message:)
    @application = application
    @event_type = event_type
    @severity = severity
    @timestamp = timestamp
    @message = message
  end
end
