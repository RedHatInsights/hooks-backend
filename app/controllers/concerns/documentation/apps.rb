# frozen_string_literal: true

require 'open_api'

module Documentation
  module Apps
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      api :index do
        desc 'Lists all apps requested'

        param_ref :RHIdentity

        response 200, 'lists all apps requested', 'application/vnd.api+json', data: {
          data: [:App],
          included: [{
            one_of: %i[EventType Level]
          }]
        }
      end

      api :show do
        desc 'Shows the requested app'

        param_ref :RHIdentity
        path! :id, Integer, example: 1

        response 200, 'shows the requested app', 'application/vnd.api+json', data: {
          data: :App,
          included: [{
            one_of: %i[EventType Level]
          }]
        }
      end

      components do
        schema :App => [{
          id: { type: String, desc: 'Identifier of the application', example: '6' },
          # There is an issue in ZRO: https://github.com/zhandao/zero-rails_openapi/issues/50 for this prop
          'type' => { type: String, desc: 'Type of the returned record', enum: ['app'] },
          attributes: {
            name: {
              type: String,
              desc: 'Name of the application, used to identify the sender in messages',
              example: 'hooks'
            },
            title: {
              type: String,
              desc: 'Title of the application, shown to the user when configuring filters',
              example: 'Hooks - The service that allows you to hook into stuff'
            }
          },
          relationships: {
            event_types: :Relationships
          }
        }, desc: 'Application object properties']
      end

      components do
        schema :EventType => [{
          id: { type: String, desc: 'Identifier of the event type', example: '6' },
          # There is an issue in ZRO: https://github.com/zhandao/zero-rails_openapi/issues/50 for this prop
          'type' => { type: String, desc: 'Type of the returned record', enum: ['event_type'] },
          attributes: {
            name: {
              type: String,
              desc: 'Identifier of the event type, used to identify the event type in messages',
              example: 'Something'
            },
            title: {
              type: String,
              desc: 'Human readable description of the event type, shown to the user when configuring filters',
              example: 'Something interesting happened'
            }
          },
          relationships: {
            levels: :Relationships
          }
        }, desc: 'Event type record properties']
      end

      components do
        schema :Level => [{
          id: { type: String, desc: 'Identifier of the level record', example: '6' },
          # There is an issue in ZRO: https://github.com/zhandao/zero-rails_openapi/issues/50 for this prop
          'type' => { type: String, desc: 'Type of the returned record', enum: ['level'] },
          attributes: {
            title: {
              type: String,
              desc: 'Title of the level, shown to the user when configuring filters',
              example: 'Hooks - The service that allows you to hook into stuff'
            }
          }
        }, desc: 'Level record properties']
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
