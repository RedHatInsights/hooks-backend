# frozen_string_literal: true

require 'rake/testtask'
require 'fileutils'
require 'tempfile'

desc 'Run tests and rubocop'
namespace :test do
  task :validate do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
  end
end

desc 'Run checks'
namespace :check do
  task :matching_docs do
    tmpfile = Tempfile.new
    tmpfile.close
    rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
    swagger_doc = File.join(rails_root, 'swagger/v1/swagger.json')
    FileUtils.copy swagger_doc, tmpfile.path
    ENV['SKIP_COVERAGE'] = 'true'
    Rake::Task['rswag:specs:swaggerize'].invoke
    unless FileUtils.compare_file(swagger_doc, tmpfile.path)
      # rubocop:disable Style/StderrPuts
      STDERR.puts 'The swagger docs were not updated'
      # rubocop:enable Style/StderrPuts
      exit 1
    end
  ensure
    tmpfile.unlink
  end
end

# rubocop:disable Lint/HandleExceptions
begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  # Don't register a task if rubocop is not available
end
# rubocop:enable Lint/HandleExceptions
