# frozen_string_literal: true

require 'optparse'
require_relative '../notifications'

COUNT = (ENV['TEST_COUNT'] || 1).to_i
app = COUNT > 1 ? 'BenchmarkApp' : 'TestApp'

# rubocop:disable Metrics/BlockLength
namespace :notifications do
  desc 'Push a message to local kafka'
  task send: :environment do
    require 'kafka'

    options = {}
    op = OptionParser.new do |opts|
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
      opts.on('-l', '--level {level}', 'Message level', String) do |level|
        options[:level] = level
      end
      opts.on('-u', '--account_id {account_id}', 'Account_id that sends the message', String) do |account_id|
        options[:account_id] = account_id
      end
    end
    op.parse(ARGV.drop(2))

    options[:application] ||= app
    options[:event_type] ||= 'TestEvent'
    options[:timestamp] ||= Time.current
    options[:level] ||= 'Info'
    options[:message] ||= 'Hello world!'
    options[:account_id] ||= Account.find_or_create_by(id: '00000000-0000-0000-0000-000000000000').id

    host = ENV['KAFKA_BROKER_HOST'] || 'localhost'
    kafka = Kafka.new(["#{host}:29092"], client_id: 'test-push')
    counter = 0
    while counter < COUNT
      producer = kafka.producer
      count = [(COUNT - counter), 1000].min
      count.times { producer.produce(options.to_json, topic: Notifications::INCOMING_TOPIC) }
      producer.deliver_messages
      counter += count
    end
    Rails.logger.info("Sent #{COUNT} messages with json: #{options.to_json}")
  end
  # rubocop:enable Metrics/BlockLength
end
