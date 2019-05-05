# frozen_string_literal: true

require 'sinatra'

MAX = (ENV['TEST_COUNT'] || 0).to_i

counter = 1
started_at = Time.now

post '/logger' do
  puts "A message was received: #{JSON.parse(request.body.read)}"
end

post '/benchmark' do
  puts "A message was received: #{JSON.parse(request.body.read)}"
  counter += 1
  if counter > MAX
    puts "BENCHMARK:#{Time.now - started_at}"
    Process.kill 'TERM', Process.pid
  end
end
