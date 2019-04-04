# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

endpoint_spec = {
  attributes: simple_spec(%i[name url] => :string,
                          :active => :boolean,
                          :filter_count => :integer)
}.merge simple_spec(%i[type id] => :string)

incoming_endpoint_spec = simple_spec(
  %i[name type url] => :string,
  :active => :boolean
).merge(
  filters: {
    type: :array,
    items: incoming_filter_spec
  }
)

# rubocop:disable Metrics/BlockLength
describe 'endpoints API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/endpoints" do
    get 'List all endpoints' do
      tags 'endpoint'
      description 'Lists all endpoints requested'
      consumes 'application/json'
      produces 'application/json'
      operationId 'ListEndpoints'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :page, in: :query, scehma: { type: :integer }, required: false
      parameter name: :per_page, in: :query, scehma: { type: :integer }, required: false
      parameter name: :order, in: :query, scehma: { type: :string }, required: false

      response '200', 'lists all endpoints requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     properties: endpoint_spec
                   }
                 },
                 meta: {
                   type: :object,
                   properties: simple_spec(%i[page per_page total] => :integer)
                 }
               }
        examples 'application/json' => {
          data: [
            {
              type: 'endpoint',
              id: '1',
              attributes: {
                name: 'my endpoint',
                url: 'http://dev.null',
                active: true,
                filter_count: 15
              }
            }
          ],
          meta: {
            page: 1,
            per_page: 10,
            total: 2
          }
        }

        before do |example|
          endpoint = FactoryBot.build(:endpoint)
          endpoint.account = account
          endpoint.save!
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end

    post 'Create and endpoint' do
      tags 'endpoint'
      description 'Shows the requested endpoint'
      consumes 'application/json'
      produces 'application/json'
      operationId 'CreateEndoint'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :endpoint, in: :body, schema: {
        type: :object,
        properties: incoming_endpoint_spec,
        required: %w[name url type]
      }

      response '201', 'endpoint created' do
        let(:'X-RH-IDENTITY') { encoded_header }
        let(:apps) { FactoryBot.create_list(:app, 2, :with_event_type) }
        let(:event_types) { apps.map(&:event_types).flatten }
        let(:levels) { event_types.map(&:levels).flatten }
        let(:endpoint) do
          {
            endpoint: {
              url: 'foo',
              name: 'bar',
              filters: [
                {
                  app_ids: apps.map(&:id),
                  event_type_ids: event_types.map(&:id),
                  level_ids: levels.map(&:id)
                }
              ]
            }
          }
        end

        run_test! do |response|
          id = JSON.parse(response.body)['data']['id']
          endpoint = Endpoint.find(id)
          filter = endpoint.filters.first
          created_event_types = filter.apps.map(&:event_types).flatten
          created_levels = created_event_types.map(&:levels).flatten
          expect(filter.apps).to match(apps)
          expect(created_event_types).to match(event_types)
          expect(created_levels).to match(levels)
        end
      end

      response '422', 'invalid request' do
        let(:'X-RH-IDENTITY') { encoded_header }
        let(:endpoint) { { url: 'foo' } }

        run_test! do |response|
          expect(response.code).to eq('422')
          result = JSON.parse(response.body)
          expect(result['errors']['name']).to include("can't be blank")
        end
      end
    end
  end

  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/endpoints/{id}" do
    get 'Show an endpoint' do
      tags 'endpoint'
      description 'Shows the requested endpoint'
      consumes 'application/json'
      produces 'application/json'
      operationId 'ShowEndpoint'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, :in => :path, :type => :integer

      response '200', 'shows the requested endpoint' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: endpoint_spec
               }
        examples 'application/json' => {
          data: {
            type: 'endpoint',
            id: '1',
            attributes: {
              name: 'my endpoint',
              url: 'http://dev.null',
              active: true,
              filter_count: 15
            }
          }
        }

        let(:id) do
          endpoint = FactoryBot.build(:endpoint)
          endpoint.account = account
          endpoint.save!
          endpoint.id
        end

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end

    put 'Update an endpoint' do
      tags 'endpoint'
      description 'Updates the requested endpoint'
      consumes 'application/json'
      produces 'application/json'
      operationId 'UpdateEndpoint'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, :in => :path, :type => :integer
      parameter name: :endpoint, in: :body, schema: {
        type: :object,
        properties: incoming_endpoint_spec.deep_merge(
          filters: {
            items: {
              properties: simple_spec(_destroy: :boolean)
            }
          }
        )
      }

      let(:'X-RH-IDENTITY') { encoded_header }
      let(:endpoint_object) do
        endpoint = FactoryBot.build(:endpoint)
        endpoint.account = account
        endpoint.save!
        endpoint
      end

      let(:id) do
        endpoint_object.id
      end

      response '200', 'endpoint updated' do
        let(:endpoint) { { url: 'foo', name: 'bar' } }
        schema type: :object,
               properties: {
                 data: endpoint_spec
               }

        before { |example| submit_request example.metadata }

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)

          endpoint = Endpoint.find(id)
          expect(endpoint.url).to eq('foo')
          expect(endpoint.name).to eq('bar')
        end
      end

      response '200', 'endpoint updated' do
        let(:endpoint) do
          {
            endpoint: {
              url: 'foo',
              name: 'bar',
              filters: [
                {
                  app_ids: [],
                  event_type_ids: [],
                  level_ids: []
                }
              ]
            }
          }
        end

        schema type: :object,
               properties: {
                 data: endpoint_spec
               }

        before { |example| submit_request example.metadata }

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)

          endpoint = Endpoint.includes(:filters).find(id)
          expect(endpoint.url).to eq('foo')
          expect(endpoint.name).to eq('bar')
          expect(endpoint.filters.count).to eq(1)
        end
      end

      response '200', 'endpoint updated' do
        let(:endpoint_filter) do
          endpoint_object.filters.create(account: endpoint_object.account)
        end

        let(:endpoint) do
          {
            endpoint: {
              url: 'foo',
              name: 'bar',
              filters: [
                {
                  id: endpoint_filter.id,
                  _destroy: true
                }
              ]
            }
          }
        end

        schema type: :object,
               properties: {
                 data: endpoint_spec
               }

        before { |example| submit_request example.metadata }

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)

          endpoint = Endpoint.includes(:filters).find(id)
          expect(endpoint.url).to eq('foo')
          expect(endpoint.name).to eq('bar')
          expect(endpoint.filters.count).to eq(0)
        end
      end
    end

    delete 'Destroy an endpoint' do
      tags 'endpoint'
      description 'Destroys the requested endpoint'
      consumes 'application/json'
      produces 'application/json'
      operationId 'DestroyEndpoint'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, :in => :path, :type => :integer

      let(:'X-RH-IDENTITY') { encoded_header }
      let(:id) do
        endpoint = FactoryBot.build(:endpoint)
        endpoint.account = account
        endpoint.save!
        endpoint.id
      end

      response '204', 'endpoint destroyed' do
        before { |example| submit_request example.metadata }

        it 'returns a valid 204 response' do |example|
          assert_response_matches_metadata(example.metadata)
          expect(Endpoint.where(:id => id).all.count).to eq(0)
        end
      end
    end
  end

  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/endpoints/{id}/test" do
    post 'Send a test message through endpoint' do
      tags 'endpoint'
      description 'Send a test message to the endpoint'
      consumes 'application/json'
      produces 'application/json'
      operationId 'TestEndpoint'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, :in => :path, :type => :integer

      let(:'X-RH-IDENTITY') { encoded_header }
      let(:endpoint) do
        endpoint = FactoryBot.build(:endpoint)
        endpoint.account = account
        endpoint.save!
        endpoint
      end
      let(:id) do
        endpoint.id
      end

      response '204', 'Sent successfully' do
        before do |_example|
          expect_any_instance_of(Endpoint).to receive(:send_message).with(
            timestamp: anything,
            level: 'Test',
            message: 'Test message from webhooks'
          )
        end

        run_test!
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
