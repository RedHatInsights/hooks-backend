# frozen_string_literal: true

require 'optparse'
require_relative '../notifications'

# rubocop:disable Metrics/BlockLength
namespace :notifications do
  desc 'Push a message to local kafka'
  task send: :environment do |args|
    require 'kafka'

    options = {}
    OptionParser.new(args) do |opts|
      opts.banner = 'Usage: rake notifications:send [options]'
      opts.on('-m', '--message {message}', 'A message to send', String) do |message|
        options[:message] = message
      end
      opts.on('-a', '--app {application}', 'Application to simulate', String) do |application|
        options[:application] = application
      end
      opts.on('-e', '--event {event}', 'Event type to simulate', String) do |event|
        options[:event_type] = event
      end
      opts.on('-s', '--severity {severity}', 'Message severity', String) do |severity|
        options[:severity] = severity
      end
      opts.on('-a', '--app {application}', 'Application to simulate', String) do |application|
        options[:application] = application
      end
    end.parse!

    options[:application] ||= 'TestApp'
    options[:event_type] ||= 'TestEvent'
    options[:timestamp] ||= Time.current
    options[:severity] ||= 'Info'
    options[:message] ||= 'Hello world!'

    host = ENV['KAFKA_BROKER_HOST'] || 'localhost'
    kafka = Kafka.new(["#{host}:29092"], client_id: 'test-push')
    kafka.deliver_message(options.to_json, topic: Notifications::INCOMING_TOPIC)
  end
  # rubocop:enable Metrics/BlockLength
end
