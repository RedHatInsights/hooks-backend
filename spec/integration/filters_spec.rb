# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

relationship_spec = {
  type: :object,
  properties: {
    data: {
      type: :array,
      items: {
        type: :object,
        properties: simple_spec(%i[id type] => :string)
      }
    }
  }
}

filter_spec = {
  attributes: simple_spec(:enabled => :boolean),
  relationships: {
    type: :object,
    properties: {
      apps: relationship_spec,
      event_types: relationship_spec,
      severity_filters: relationship_spec
    }
  }
}.merge simple_spec(%i[type id] => :string)

# rubocop:disable Metrics/BlockLength
describe 'filters API' do
  path '/r/insights/platform/notifications/filters' do
    get 'List all filters' do
      tags 'filter'
      description 'Lists all filters requested'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }

      response '200', 'lists all filters requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: filter_spec
                   }
                 }
               }
        examples 'application/json' => {
          data: [
            {
              type: 'filter',
              id: '1',
              attributes: {
                enabled: true
              },
              relationships: {
                apps: {
                  data: [{ :id => '1', :type => 'app' }]
                },
                event_types: {
                  data: [{ :id => '1', :type => 'event_type' }, { :id => 2, :type => 'event_type' }]
                },
                severity_filters: {
                  data: [{ :id => '1', :type => 'severity_filter' }, { :id => 2, :type => 'severity_filter' }]
                }
              }
            }
          ]
        }

        before do |example|
          app = FactoryBot.create(:app, :with_event_type)
          Builder::Filter.build!(account) do |f|
            f.application(app.name)
             .event_type(app.event_types.first.name)
            f.severities('low', 'medium', 'high')
          end
          submit_request example.metadata
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path '/r/insights/platform/notifications/endpoints/{endpoint_id}/filters' do
    get 'List all filters associated to endpoint' do
      tags 'filter'
      description 'Lists all filters associated to endpoint'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :endpoint_id, in: :path, :type => :integer

      response '200', 'lists all filters requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: filter_spec
                   }
                 }
               }
        examples 'application/json' => {
          data: [
            {
              type: 'filter',
              id: '1',
              attributes: {
                name: 'my filter',
                url: 'http://dev.null',
                active: true,
                filter_count: 15
              }
            }
          ]
        }

        let(:endpoint_id) do
          endpoint = FactoryBot.build(:endpoint)
          endpoint.account = account
          endpoint.save!
          endpoint.filters << Builder::Filter.build!(account) { |f| }
          endpoint.id
        end

        before do |example|
          app = FactoryBot.create(:app, :with_event_type)
          Builder::Filter.build!(account) do |f|
            f.application(app.name)
             .event_type(app.event_types.first.name)
            f.severities('low', 'medium', 'high')
          end
          submit_request example.metadata
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
          data = JSON.parse(response.body)['data']
          data.each do |filter|
            expect(Filter.find(filter['id']).account_id).to eq(account.id)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
