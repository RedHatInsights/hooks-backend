# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable Metrics/BlockLength
describe 'filters API' do
  path "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}/apps/register" do
    post 'Register an app' do
      tags 'filter'
      description 'Register an application'
      consumes 'application/json'
      produces 'application/json'
      operationId 'RegisterApp'
      parameter name: :application, in: :body, schema: {
        type: :object,
        properties: {
          application: {
            type: :object,
            properties: simple_spec(%i[name title] => :string)
          },
          event_types: {
            type: :array,
            items: {
              type: :object,
              properties: {
                levels: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: simple_spec(%i[name title] => :string, :id => :integer)
                  }
                }
              }.merge(simple_spec(%i[name title] => :string, :id => :integer))
            }
          }
        }
      }

      response '200', 'registers the application' do
        let(:application) do
          app = { :name => 'app-1', :title => 'Application 1' }
          levels = [
            { :id => 1, :name => 'level-1', :title => 'Low' },
            { :id => 2, :name => 'level-2', :title => 'High' }
          ]
          event_types = [
            { :id => 1, :name => 'something', :title => 'Something', :levels => [] },
            { :id => 2, :name => 'something-else', :title => 'Something else', :levels => levels }
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
