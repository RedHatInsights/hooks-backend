rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

rails_env = ENV['RAILS_ENV'] || 'development'
config_file = File.join(rails_root, 'config', 'resque.yml')

resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]

# Logging
Resque.logger = ::Logger.new(STDOUT)
Resque.logger.level = Logger::INFO

