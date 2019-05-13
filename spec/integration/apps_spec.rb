# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable Metrics/BlockLength
describe 'apps API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/apps" do
    get 'List all apps' do
      tags 'app'
      description 'Lists all apps requested'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      operationId 'ListApps'
      parameter '$ref' => '#/parameters/RHIdentity'

      response '200', 'lists all apps requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     '$ref' => '#/definitions/app'
                   }
                 },
                 included: {
                   type: :array,
                   items: {
                     oneOf: [
                       { '$ref' => '#/definitions/event_type' },
                       { '$ref' => '#/definitions/level' }
                     ]
                   }
                 },
                 meta: {
                   '$ref' => '#/definitions/metadata'
                 },
                 links: {
                   '$ref' => '#/definitions/links'
                 }
               }

        examples 'application/vnd.api+json' => {
          data: [
            {
              type: 'app',
              id: '3',
              attributes: {
                name: 'notifications'
              },
              relationships: {
                event_types: {
                  data: [
                    { id: '11', type: 'event_type' },
                    { id: '12', type: 'event_type' }
                  ]
                }
              }
            }
          ],
          included: [
            { id: '11', type: 'event_type', attributes: { name: 'something' },
              relationships: {
                levels: {
                  data: [
                    { id: '1', type: 'level' }
                  ]
                }
              } },
            { id: '12', type: 'event_type', attributes: { name: 'something-else' } },
            { id: '1', type: 'level', attributes: { title: 'level-title' } }
          ],
          meta: {
            total: 1,
            limit: 100,
            offset: 0
          }
        }

        before do |example|
          FactoryBot.create(:app, :with_event_type)
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/apps/{id}" do
    get 'Show an app' do
      tags 'app'
      description 'Shows the requested app'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      operationId 'ShowApp'
      parameter '$ref' => '#/parameters/RHIdentity'
      parameter name: :id, :in => :path, :type => :integer

      response '200', 'shows the requested app' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   '$ref' => '#/definitions/app'
                 },
                 included: {
                   type: :array,
                   items: {
                     oneOf: [
                       { '$ref' => '#/definitions/event_type' },
                       { '$ref' => '#/definitions/level' }
                     ]
                   }
                 }
               }
        examples 'application/vnd.api+json' => {
          data: {
            type: 'app',
            id: '3',
            attributes: {
              name: 'notifications',
              title: 'Notifications'
            },
            relationships: {
              event_types: {
                data: [
                  { id: '11', type: 'event_type' },
                  { id: '12', type: 'event_type' }
                ]
              }
            }
          },
          included: [
            { id: '11', type: 'event_type', attributes: { name: 'something', title: 'Something' },
              relationships: {
                levels: {
                  data: [
                    { id: '1', type: 'level' }
                  ]
                }
              } },
            { id: '12', type: 'event_type',
              attributes: { name: 'something-else', title: 'Something else' } },
            { id: '1', type: 'level', attributes: { title: 'level-title' } }
          ]
        }

        let(:id) { FactoryBot.create(:app, :with_event_type).id }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
