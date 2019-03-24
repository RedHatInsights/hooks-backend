# frozen_string_literal: true

require 'sinatra'

post '/logger' do
  puts "A message was received: #{JSON.parse(request.body.read)}"
end
