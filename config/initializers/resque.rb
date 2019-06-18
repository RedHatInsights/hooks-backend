# frozen_string_literal: true

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

rails_env = ENV['RAILS_ENV'] || 'development'
config_file = File.join(rails_root, 'config', 'resque.yml')

resque_config = YAML.safe_load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]

# Logging
Resque.logger = ::Logger.new(STDOUT)
Resque.logger.level = Logger::INFO

Resque.before_child_exit do
  # Do nothing
  # If left undefined, logs get spammed with
  #   rake aborted!
  #   NoMethodError: undefined method `empty?' for nil:NilClass
  #   /usr/share/gems/gems/resque-2.0.0/lib/resque/worker.rb:647:
  #     in `run_hook'
  #   /usr/share/gems/gems/resque-multi-job-forks-0.5.0/lib/resque-multi-job-forks.rb:124:
  #     in `release_fork'
  #   /usr/share/gems/gems/resque-multi-job-forks-0.5.0/lib/resque-multi-job-forks.rb:105:
  #     in `release_and_exit!'
  #   /usr/share/gems/gems/resque-multi-job-forks-0.5.0/lib/resque-multi-job-forks.rb:35:in
  #     in `work_with_multi_job_forks'
  #   /usr/share/gems/gems/resque-2.0.0/lib/resque/tasks.rb:20:in `block (2 levels) in <main>'
  #   Tasks: TOP => resque:work
end

Resque.after_fork do
  require 'prometheus_exporter/instrumentation'
  PrometheusExporter::Instrumentation::Process.start
end
