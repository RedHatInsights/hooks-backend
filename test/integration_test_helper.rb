# frozen_string_literal: true

require 'test_helper'

class CommitteeTest < ActionDispatch::IntegrationTest
  include Committee::Test::Methods
  # include Rack::Test::Methods

  def committee_options
    @committee_options ||= {
      schema: Committee::Drivers.load_from_file('swagger/v1/openapi.json'),
      # prefix: "/api/hooks",
      validate_success_only: false
    }
  end

  def request_object
    request
  end

  def response_data
    [response.status, response.headers, response.body]
  end

  def account_number
    @account_number ||= '1234'
  end

  def account
    @account ||= Account.find_or_create_by(:account_number => account_number)
  end

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
end
