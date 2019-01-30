# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'minitest/reporters'
require 'minitest/mock'
require 'mocha/minitest'

FactoryBot.definition_file_paths = [Rails.root.join('test', 'factories')]
FactoryBot.find_definitions

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest_5
    with.library :rails
  end
end

class ActiveSupport::TestCase
  self.use_transactional_tests = true
end
