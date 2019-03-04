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

  attr_reader :application, :event_type, :level, :timestamp, :message, :account_id

  # rubocop:disable Metrics/ParameterLists
  def initialize(application:, event_type:, level:, timestamp:, message:, account_id:)
    @application = application
    @event_type = event_type
    @level = level
    @timestamp = timestamp
    @message = message
    @account_id = account_id
  end
  # rubocop:enable Metrics/ParameterLists

  def to_h
    { :application => application,
      :event_type => event_type,
      :level => level,
      :timestamp => timestamp,
      :message => message,
      :account_id => account_id }
  end

  def merge(other)
    self.class.new(to_h.merge(other))
  end
end
