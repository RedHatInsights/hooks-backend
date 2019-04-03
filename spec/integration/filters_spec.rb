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
      levels: relationship_spec
    }
  }
}.merge simple_spec(%i[type id] => :string)

# rubocop:disable Metrics/BlockLength
describe 'filters API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/filters" do
    get 'List all filters' do
      tags 'filter'
      description 'Lists all filters requested'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :page, in: :query, scehma: { type: :integer }, required: false
      parameter name: :per_page, in: :query, scehma: { type: :integer }, required: false

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
                 },
                 meta: {
                   type: :object,
                   properties: simple_spec(%i[page per_page total] => :integer)
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
                levels: {
                  data: [{ :id => '1', :type => 'level' }, { :id => 2, :type => 'level' }]
                }
              }
            }
          ],
          meta: {
            page: 1,
            per_page: 10,
            total: 3
          }
        }

        before do |example|
          app = FactoryBot.create(:app, :with_event_type)
          Builder::Filter.build!(account) do |f|
            f.application(app.name)
             .event_type(app.event_types.first.external_id)
             .levels(app.event_types.first.levels.pluck(:external_id))
          end
          submit_request example.metadata
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end

    post 'Create a filter' do
      tags 'filter'
      description 'Creates a filter'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :filter, in: :body, schema: incoming_filter_spec

      response '201', 'creates a filter' do
        let(:'X-RH-IDENTITY') { encoded_header }
        let(:filter) do
          app = FactoryBot.create(:app, :with_event_type)
          filter = { :app_ids => [app.id],
                     :event_type_ids => app.event_types.pluck(:id),
                     :levels => app.event_types.first.levels.pluck(:id) }
          { :filter => filter }
        end
        schema type: :object,
               properties: {
                 data: filter_spec
               }

        run_test!
      end
    end
  end

  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/filters/{id}" do
    delete 'Delete a filter' do
      tags 'filter'
      description 'Lists all filters associated to endpoint'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :id, in: :path, :type => :integer

      response '204', 'destroys the filter' do
        let(:'X-RH-IDENTITY') { encoded_header }

        let(:id) do
          filter = Builder::Filter.build!(account) { |f| }
          filter.id
        end

        before do |example|
          submit_request example.metadata
        end

        it 'returns a valid 204 response' do |example|
          assert_response_matches_metadata(example.metadata)
          expect(Filter.where(:id => id).all.count).to eq(0)
        end
      end
    end
  end

  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/endpoints/{endpoint_id}/filters" do
    parameter name: :endpoint_id, in: :path, :type => :integer
    let(:endpoint_id) do
      endpoint = FactoryBot.build(:endpoint)
      endpoint.account = account
      endpoint.save!
      endpoint.filters << Builder::Filter.build!(account) { |f| }
      endpoint.id
    end

    get 'List all filters associated to endpoint' do
      tags 'filter'
      description 'Lists all filters associated to endpoint'
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
                name: 'my filter',
                url: 'http://dev.null',
                active: true,
                filter_count: 15
              }
            }
          ]
        }

        before do |example|
          app = FactoryBot.create(:app, :with_event_type)
          Builder::Filter.build!(account) do |f|
            f.application(app.name)
             .event_type(app.event_types.first.external_id)
             .levels(app.event_types.first.levels.pluck(:external_id))
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
    post 'Create a filter' do
      tags 'filter'
      description 'Creates a filter'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }
      parameter name: :filter, in: :body, schema: {
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
          levels: {
            type: :array,
            items: :integer
          }
        }
      }

      response '201', 'creates a filter' do
        let(:'X-RH-IDENTITY') { encoded_header }

        let(:filter) do
          app = FactoryBot.create(:app, :with_event_type)
          filter = { :app_ids => [app.id],
                     :event_type_ids => app.event_types.pluck(:id),
                     :levels => app.event_types.first.levels.pluck(:id) }
          { :filter => filter }
        end
        schema type: :object,
               properties: {
                 data: filter_spec
               }

        run_test!
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
