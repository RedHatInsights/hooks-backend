# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

endpoint_spec = {
  attributes: simple_spec(%i[name url] => :string,
                          :active => :boolean,
                          :filter_count => :integer)
}.merge simple_spec(%i[type id] => :string)

# rubocop:disable Metrics/BlockLength
describe 'endpoints API' do
  path '/r/insights/platform/notifications/endpoints' do
    get 'List all endpoints' do
      tags 'endpoint'
      description 'Lists all endpoints requested'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }

      response '200', 'lists all endpoints requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     properties: endpoint_spec
                   }
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
          ]
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
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :endpoint, in: :body, schema: {
        type: :object,
        properties: simple_spec(%i[name type url] => :string, :active => :boolean),
        required: %w[name url type]
      }

      response '201', 'endpoint created' do
        let(:'X-RH-IDENTITY') { encoded_header }
        let(:endpoint) { { url: 'foo', name: 'bar' } }
        schema type: :object,
               properties: {
                 data: endpoint_spec
               }

        run_test!
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

  path '/r/insights/platform/notifications/endpoints/{id}' do
    get 'Show an endpoint' do
      tags 'endpoint'
      description 'Shows the requested endpoint'
      consumes 'application/json'
      produces 'application/json'
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
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, :in => :path, :type => :integer
      parameter name: :endpoint, in: :body, schema: {
        type: :object,
        properties: simple_spec(%i[name type url] => :string, :active => :boolean)
      }

      let(:'X-RH-IDENTITY') { encoded_header }
      let(:id) do
        endpoint = FactoryBot.build(:endpoint)
        endpoint.account = account
        endpoint.save!
        endpoint.id
      end

      response '200', 'endpoint updated' do
        let(:'X-RH-IDENTITY') { encoded_header }
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
    end
  end
end
# rubocop:enable Metrics/BlockLength
