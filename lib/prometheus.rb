# frozen_string_literal: true

class Prometheus
  class << self
    def send_json(**options)
      return unless available?

      PrometheusExporter::Client.default.send_json(**options)
    end

    def available?
      Rails.env != 'test' && ENV['PROMETHEUS_EXPORTER_HOST'] && ENV['PROMETHEUS_EXPORTER_PORT']
    end
  end
end
