# frozen_string_literal: true

class ApplicationConsumer < Racecar::Consumer
  # rubocop:disable Metrics/MethodLength
  def with_metrics
    puts PrometheusExporter::Client.default.inspect
    start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    yield
  rescue RuntimeError => e
    raise e
  ensure
    duration = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - start
    PrometheusExporter::Client.default.send_json(
      type: 'racecar',
      name: self.class.name,
      duration: duration
    )
  end
  # rubocop:enable Metrics/MethodLength
end
