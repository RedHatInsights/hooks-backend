require 'rake/testtask'

desc 'Run tests and rubocop'
namespace :test do
  task :validate do
    Rake::Task['test'].invoke
    Rake::Task['spec'].invoke
  end
end
