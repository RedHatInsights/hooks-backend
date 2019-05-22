# frozen_string_literal: true

require 'open_api'

desc 'Generate openapi V3 documentation'
namespace :documentation do
  task :generate => :environment do
    if !File.file?('swagger/v1/openapi.json') || ENV['force']
      when_writing('Generating documentation') do
        OpenApi.write_docs
      end
    else
      rake_output_message 'File exists, skipping docs generation.'\
                          ' Use "rake documentation:generate force=true" to force'
    end
  end
end

task :test => 'documentation:generate'
