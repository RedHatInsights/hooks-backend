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

# rubocop:disable Metrics/BlockLength
describe 'apps API' do
  path '/r/insights/platform/notifications/apps' do
    after { App.destroy_all }
    get 'List all apps' do
      tags 'app'
      description 'Lists all apps requested'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-RH-IDENTITY', in: :header, schema: { type: :string }

      response '200', 'lists all apps requested' do
        let(:'X-RH-IDENTITY') { encoded_header }
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     properties: {
                       type: { type: :string },
                       id: { type: :string },
                       attributes: {
                         type: :object,
                         properties: {
                           name: { type: :string }
                         },
                         relationships: {
                           type: :object,
                           properties: {
                             event_types: {
                               type: :array,
                               items: {
                                 properties: {
                                   type: :string,
                                   id: :integer
                                 }
                               }
                             }
                           }
                         }
                       }
                     }
                   },
                   included: {
                     type: :array,
                     items: {
                       properties: {
                         id: { type: :integer },
                         type: { type: :string },
                         attributes: {
                           name: { type: :string }
                         }
                       }
                     }
                   }
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
            { id: '11', type: 'event_type', attributes: { name: 'something' } },
            { id: '12', type: 'event_type', attributes: { name: 'something-else' } }
          ]
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
end
# rubocop:enable Metrics/BlockLength
