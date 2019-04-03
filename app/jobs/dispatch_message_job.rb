# frozen_string_literal: true

require 'notifications'
require 'dispatcher'

class DispatchMessageJob < ApplicationJob
  retry_on(::Notifications::RecoverableError, wait: :exponentially_longer, attempts: 3) do |job, error|
    Rails.logger.warn("Discarding message #{job.message} after too many retries for #{error.message}")
  end

  def perform(message_hash)
    Rails.logger.debug("Received a message to dispatch: #{message_hash}")

    begin
      message = Message.from_json(message_hash)
    rescue ArgumentError => e
      raise ::Notifications::RecoverableError, e.inspect
    end

    dispatcher = ::Dispatcher.new(message)
    dispatcher.dispatch!

    Rails.logger.debug("Successfully dispatched message #{message}")
  end

  def message
    arguments.first
  end
end
