# frozen_string_literal: true

require 'rake/testtask'

desc 'Run tests and rubocop'
namespace :test do
  task :validate do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
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
