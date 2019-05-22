# frozen_string_literal: true

require 'open_api'

module Documentation
  module Filters
    extend ActiveSupport::Concern

    included do
      api :show do
        desc 'Show the filter of the endpoint'

        param_ref :RHIdentity
        path! :endpoint_id, Integer, example: 1

        response 200, 'Show the filter of the endpoint', 'application/vnd.api+json', data: {
          data: {
            id: String,
            'type' => { type: String, enum: ['filter'] },
            attributes: {
              enabled: 'boolean'
            },
            relationships: {
              apps: :Relationships,
              event_types: :Relationships,
              levels: :Relationships,
              endpoint: :Relationship
            }
          }
        }
      end
    end
  end
end
