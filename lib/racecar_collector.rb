# frozen_string_literal: true

class RacecarCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @racecar_message_duration_seconds =
      PrometheusExporter::Metric::Counter.new(
        'racecar_message_duration_seconds', 'Total time spent consuming racecar messages.'
      )

    @racecar_messages_total =
      PrometheusExporter::Metric::Counter.new(
        'racecar_messages_total', 'Total number of racecar messages consumed.'
      )
  end

  def type
    'racecar'
  end

  def collect(obj)
    custom_labels = obj.fetch('custom_labels', {})
    labels = { consumer_name: obj['name'] }.merge(custom_labels)

    @racecar_message_duration_seconds.observe(obj['duration'], labels)
    @racecar_messages_total.observe(1, labels)
  end

  def metrics
    [@racecar_messages_total, @racecar_message_duration_seconds]
  end
end
