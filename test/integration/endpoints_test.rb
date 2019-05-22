# frozen_string_literal: true

require 'integration_test_helper'

# rubocop:disable Metrics/ClassLength
class EndpointsTest < CommitteeTest
  test 'Lists endpoints according to schema' do
    endpoint = FactoryBot.build(:endpoint)
    endpoint.account = account
    endpoint.save!

    get endpoints_path, headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform
  end

  test 'Creates an endpoint' do
    apps = FactoryBot.create_list(:app, 2, :with_event_type)
    event_types = apps.map(&:event_types).flatten
    levels = event_types.map(&:levels).flatten
    endpoint = {
      endpoint: {
        url: 'foo',
        name: 'bar',
        filter: {
          app_ids: apps.map(&:id),
          event_type_ids: event_types.map(&:id),
          level_ids: levels.map(&:id)
        }
      }
    }

    post endpoints_path, params: endpoint, as: :json, headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform

    id = JSON.parse(response.body)['data']['id']
    endpoint = Endpoint.find(id)
    filter = endpoint.filter
    created_event_types = filter.apps.map(&:event_types).flatten
    created_levels = created_event_types.map(&:levels).flatten
    assert_equal apps, filter.apps
    assert_equal event_types, created_event_types
    assert_equal levels, created_levels
  end

  test 'Fails to create an endpoint with 422' do
    endpoint = { endpoint: { url: 'foo' } }

    post endpoints_path, params: endpoint, as: :json, headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform

    assert_response 422
    data = JSON.parse(response.body)
    name_error = data['errors'].find { |e| e['source']&.fetch('pointer') == '/data/attributes/name' }
    assert_match(/can't be blank/, name_error['detail'])
  end

  test 'Shows a single endpoint' do
    id = begin
           endpoint = FactoryBot.build(:endpoint)
           endpoint.account = account
           endpoint.save!
           endpoint.id
         end

    get endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform
  end

  test 'Updates an endpoint' do
    endpoint_object = begin
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint
    end
    id = endpoint_object.id

    endpoint = { endpoint: { url: 'foo', name: 'bar' } }

    put endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }, params: endpoint, as: :json

    assert_response 200
    assert_schema_conform

    endpoint = Endpoint.find(id)
    assert_equal 'foo', endpoint.url
    assert_equal 'bar', endpoint.name
  end

  test 'Updates an endpoint with filter' do
    endpoint_object = begin
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint
    end
    id = endpoint_object.id

    endpoint = {
      endpoint: {
        url: 'foo',
        name: 'bar',
        filter: {
          app_ids: [],
          event_type_ids: [],
          level_ids: []
        }
      }
    }

    put endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }, params: endpoint, as: :json

    assert_response 200
    assert_schema_conform

    endpoint = Endpoint.includes(:filter).find(id)
    assert_not_nil endpoint.filter
    assert_equal 'foo', endpoint.url
    assert_equal 'bar', endpoint.name
  end

  test 'Updates an endpoint and removes filter' do
    endpoint_object = begin
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint
    end
    id = endpoint_object.id

    endpoint_filter = endpoint_object.create_filter(account: endpoint_object.account)

    endpoint = {
      endpoint: {
        url: 'foo',
        name: 'bar',
        filter: {
          id: endpoint_filter.id,
          _destroy: true
        }
      }
    }

    put endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }, params: endpoint, as: :json

    assert_response 200
    assert_schema_conform

    endpoint = Endpoint.includes(:filter).find(id)
    assert_nil endpoint.filter
    assert_equal 'foo', endpoint.url
    assert_equal 'bar', endpoint.name
  end

  test 'destroys an endpoint' do
    endpoint_object = begin
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint
    end
    id = endpoint_object.id

    delete endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_response 204
    assert_schema_conform

    assert_equal 0, Endpoint.where(:id => id).all.count
  end

  test 'tests an endpoint' do
    endpoint = begin
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint
    end
    id = endpoint.id

    Endpoint.any_instance.expects(:send_message).with do |args|
      args[:level] == 'Test' && args[:message] == 'Test message from webhooks'
    end

    post test_endpoint_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_response 204
    assert_schema_conform
  end

  test 'Shows filters for a single endpoint' do
    id = begin
           endpoint = FactoryBot.build(:endpoint)
           endpoint.account = account
           endpoint.save!
           endpoint.create_filter(:account => account)
           endpoint.id
         end

    get endpoint_filter_path(endpoint_id: id), headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform
  end
end
# rubocop:enable Metrics/ClassLength
