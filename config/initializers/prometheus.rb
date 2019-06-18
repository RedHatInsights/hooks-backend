# frozen_string_literal: true

require 'prometheus'

if Prometheus.available?
  require 'prometheus_exporter/client'
  require 'prometheus_exporter/metric'
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/instrumentation'

  app_name = ENV['APPLICATION_TYPE']
  labels = { :app_name => app_name }
  client = PrometheusExporter::Client.new(
    host: ENV['PROMETHEUS_EXPORTER_HOST'],
    port: ENV['PROMETHEUS_EXPORTER_PORT'],
    custom_labels: labels
  )

  PrometheusExporter::Metric::Base.default_prefix = 'hooks'
  PrometheusExporter::Client.default = client

  # This reports stats per request like HTTP status and timings
  if app_name == 'hooks-backend'
    Rails.application.middleware.unshift PrometheusExporter::Middleware
    PrometheusExporter::Instrumentation::Process.start(type: 'web', labels: labels)
  end

  PrometheusExporter::Instrumentation::Process.start(type: 'master', labels: labels)
end
