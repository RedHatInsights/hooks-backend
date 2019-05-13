# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable Metrics/BlockLength
describe 'filters API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/apps/register" do
    post 'Register an app' do
      tags 'filter'
      description 'Register an application'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      operationId 'RegisterApp'
      parameter name: :application, in: :body, schema: {
        type: :object,
        properties: {
          application: {
            '$ref' => '#/definitions/app'
          },
          event_types: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: {
                  type: :string,
                  description: 'Identifier of the event type, used to identify the event type in messages',
                  example: 'something'
                },
                title: {
                  type: :string,
                  description: 'Human readable description of the event type, ' \
                               'shown to the user when configuring filters',
                  example: 'Something interesting happened'
                },
                levels: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: {
                        type: :string,
                        description: 'Identifier of the level, used to identify the level in messages',
                        example: 'low'
                      },
                      title: {
                        type: :string,
                        description: 'Human readable description of the level, ' \
                                     'shown to the user when configuring filters',
                        example: 'Low severity'
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      response '200', 'registers the application' do
        schema type: :object,
               properties: {
                 data: {
                   '$ref' => '#/definitions/app'
                 }
               }

        let(:application) do
          app = { :name => 'app-1', :title => 'Application 1' }
          levels = [
            { :id => 'level-1', :title => 'Low' },
            { :id => 'level-2', :title => 'High' }
          ]
          event_types = [
            { :id => 'something', :title => 'Something', :levels => [] },
            { :id => 'something-else', :title => 'Something else', :levels => levels }
          ]
          { :application => app, :event_types => event_types }
        end

        before do |example|
          submit_request example.metadata
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
