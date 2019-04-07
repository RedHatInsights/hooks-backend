# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# Justification: It's mostly hash test data
# rubocop:disable Metrics/MethodLength
def encoded_header
  Base64.encode64(
    {
      'identity':
      {
        'account_number': '1234',
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
    }.to_json
  )
end
# rubocop:enable Metrics/MethodLength

app_spec = {
  type: { type: :string },
  id: { type: :string },
  attributes: {
    type: :object,
    properties: {
      name: { type: :string },
      title: { type: :string }
    }
  },
  relationships: {
    type: :object,
    properties: {
      event_types: {
        type: :object,
        properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                type: { type: :string },
                id: { type: :string }
              }
            }
          }
        }
      }
    }
  }
}

event_type_spec = {
  id: { type: :string },
  type: { type: :string },
  attributes: {
    name: { type: :string },
    title: { type: :string }
  },
  relationships: {
    type: :object,
    properties: {
      levels: {
        type: :object,
        properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                title: { type: :string },
                id: { type: :string }
              }
            }
          }
        }
      }
    }
  }
}

included_event_type_spec = {
  type: :array,
  items: { properties: event_type_spec }
}

# rubocop:disable Metrics/BlockLength
describe 'apps API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/apps" do
    get 'List all apps' do
      tags 'app'
      description 'Lists all apps requested'
      consumes 'application/json'
      produces 'application/json'
      operationId 'ListApps'
      parameter name: :'X-RH-IDENTITY', in: :header, type: :string

      response '200', 'lists all apps requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     properties: app_spec
                   }
                 },
                 included: included_event_type_spec,
                 meta: {
                   type: :object,
                   properties: simple_spec(%i[page per_page total] => :integer)
                 }
               }
        examples 'application/json' => {
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
            page: 1,
            per_page: 10,
            total: 1
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
      consumes 'application/json'
      produces 'application/json'
      operationId 'ShowApp'
      parameter name: :'X-RH-IDENTITY', in: :header, type: :string
      parameter name: :id, :in => :path, :type => :integer

      response '200', 'shows the requested app' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: app_spec,
                 included: included_event_type_spec
               }
        examples 'application/json' => {
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
