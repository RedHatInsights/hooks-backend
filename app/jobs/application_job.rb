# frozen_string_literal: true

require 'notifications'
require 'prometheus'

class ApplicationJob < ActiveJob::Base
  around_perform :handle_prometheus

  # rubocop:disable Metrics/MethodLength
  def handle_prometheus
    success = false
    shutdown = false
    start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    result = yield
    success = true
    result
  rescue Notifications::RecoverableError => e
    shutdown = true
    raise e
  ensure
    duration = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - start
    Prometheus.send_json(
      type: 'resque',
      name: self.class.name,
      success: success,
      shutdown: shutdown,
      duration: duration
    )
  end
  # rubocop:enable Metrics/MethodLength
end
