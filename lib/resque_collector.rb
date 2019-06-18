# frozen_string_literal: true

class ResqueCollector < PrometheusExporter::Server::TypeCollector
  # rubocop:disable Metrics/MethodLength
  def initialize
    @resque_job_duration_seconds =
      PrometheusExporter::Metric::Counter.new(
        'resque_job_duration_seconds', 'Total time spent in resque jobs.'
      )

    @resque_jobs_total =
      PrometheusExporter::Metric::Counter.new(
        'resque_jobs_total', 'Total number of resque jobs executed.'
      )

    @resque_restarted_jobs_total =
      PrometheusExporter::Metric::Counter.new(
        'resque_restarted_jobs_total', 'Total number of resque jobs that we restarted'
      )

    @resque_failed_jobs_total =
      PrometheusExporter::Metric::Counter.new(
        'resque_failed_jobs_total', 'Total number of failed resque jobs.'
      )
  end
  # rubocop:enable Metrics/MethodLength

  def type
    'resque'
  end

  def collect(obj)
    custom_labels = obj.fetch('custom_labels', {})
    labels = { job_name: obj['name'] }.merge(custom_labels)

    @resque_job_duration_seconds.observe(obj['duration'], labels)
    @resque_jobs_total.observe(1, labels)
    @resque_restarted_jobs_total.observe(1, labels) if obj['shutdown']
    @resque_failed_jobs_total.observe(1, labels) if !obj['success'] && !obj['shutdown']
  end

  def metrics
    [
      @resque_job_duration_seconds,
      @resque_jobs_total,
      @resque_restarted_jobs_total,
      @resque_failed_jobs_total
    ]
  end
end
