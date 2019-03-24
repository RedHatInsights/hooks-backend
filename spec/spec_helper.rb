# frozen_string_literal: true

unless ENV['SKIP_COVERAGE']
  require 'simplecov'
  SimpleCov.command_name 'spec'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after(:suite) do
    File.delete(Rails.root.join('tmp', 'thumbnail.png')) if File.file?(Rails.root.join('tmp', 'thumbnail.png'))
  end
end

def account_number
  '1234'
end

def account
  Account.find_or_create_by(:account_number => account_number)
end

# Justification: It's mostly hash test data
# rubocop:disable Metrics/MethodLength
def security_header
  {
    'identity':
    {
      'account_number': account_number,
      'type': 'User',
      'user': {
        'email': 'a@b.com',
        'username': 'a@b.com',
        'first_name': 'a',
        'last_name': 'b',
        'is_active': true,
        'locale': 'en_US'
      },
      'internal': {
        'org_id': '29329'
      }
    }
  }
end
# rubocop:enable Metrics/MethodLength

def encoded_header
  Base64.encode64(security_header.to_json)
end

def simple_spec(hash)
  hash.reduce({}) do |acc, (key, value)|
    if key.is_a? Array
      key.reduce(acc) { |acc, key| acc.merge(key => { :type => value }) }
    else
      acc.merge(key => { :type => value })
    end
  end
end

# rubocop:disable Metrics/MethodLength
def incoming_filter_spec
  {
    type: :object,
    properties: {
      app_ids: {
        type: :array,
        items: :integer
      },
      event_type_ids: {
        type: :array,
        items: :integer
      },
      level_ids: {
        type: :array,
        items: :string
      }
    }
  }
end
# rubocop:enable Metrics/MethodLength
