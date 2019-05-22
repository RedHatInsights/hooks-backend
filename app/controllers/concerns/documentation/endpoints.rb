# frozen_string_literal: true

require 'open_api'

module Documentation
  # rubocop:disable Metrics/BlockLength, Metrics/ModuleLength
  module Endpoints
    extend ActiveSupport::Concern

    included do
      api :index do
        desc 'List all endpoints'

        param_ref :RHIdentity
        param_ref :Order
        param_ref :Offset
        param_ref :Limit

        response 200, 'lists all endpoints', 'application/vnd.api+json', data: {
          data: [:Endpoint],
          meta: :Metadata,
          links: :Links
        }
      end

      api :show do
        desc 'Shows the requested endpoint'

        param_ref :RHIdentity
        path! :id, Integer, example: 1

        response 200, 'Shows the requested endpoint', 'application/vnd.api+json', data: {
          data: :Endpoint
        }
      end

      incoming_endpoint_spec = {
        endpoint: {
          url: 'url',
          name: String,
          'type' => String,
          filter: {
            app_ids: [String],
            event_type_ids: [String],
            level_ids: [String]
          }
        }
      }

      api :create do
        desc 'Creates an endpoint'

        param_ref :RHIdentity

        body! :json, data: incoming_endpoint_spec

        response 201, 'Creates an endpoint', 'application/vnd.api+json', data: {
          data: :Endpoint
        }
        response 422, 'Invalid request', 'application/vnd.api+json', data: :Errors
      end

      api :update do
        desc 'Updates the requested endpoint'

        param_ref :RHIdentity
        path! :id, Integer, example: 1

        body! :json, data: incoming_endpoint_spec.deep_merge(endpoint: { filter: { _destroy: 'boolean' } })

        response 200, 'Endpoint updated', 'application/vnd.api+json', data: {
          data: :Endpoint
        }
      end

      api :destroy do
        param_ref :RHIdentity
        path! :id, Integer, example: 1

        response 204, 'Endpoint destroyed'
      end

      api :test do
        desc 'Send a test message to the endpoint'

        param_ref :RHIdentity
        path! :id, Integer, example: 1

        response 204, 'Sent successfully'
      end

      components do
        schema :Endpoint, type: {
          id: { type: String, desc: 'Identifier of the endpoint', example: '6' },
          # There is an issue in ZRO: https://github.com/zhandao/zero-rails_openapi/issues/50 for this prop
          'type' => { type: String, desc: 'Type of the returned record', enum: ['endpoint'] },
          attributes: {
            name: {
              type: String,
              desc: 'Human readable description of the endpoint',
              example: 'An endpoint'
            },
            active: {
              type: 'boolean',
              desc: 'A flag determining whether this endpoint should be used'
            },
            url: {
              type: String,
              desc: 'URL to which messages should be POSTed',
              example: 'https://devnull-as-a-service.com/dev/null'
            },
            last_delivery_status: {
              type: String,
              enum: %w[success failure],
              nullable: true,
              desc: 'Status of the last delivery'
            },
            last_delivery_time: {
              type: DateTime,
              desc: 'Timestamp of last delivery attempt',
              nullable: true
            },
            last_failure_time: {
              type: DateTime,
              desc: 'Timestamp of first failure. If the status is "failure",' \
                    ' this marks when the endpoint "went down"'
            }
          }
        }
      end
    end
  end
  # rubocop:enable Metrics/BlockLength, Metrics/ModuleLength
end
