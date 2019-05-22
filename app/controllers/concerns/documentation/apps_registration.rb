# frozen_string_literal: true

require 'open_api'

module Documentation
  module AppsRegistration
    extend ActiveSupport::Concern

    included do
      include OpenApi::DSL

      api :create do
        desc 'Register an application'

        body! :json, data: {
          application: {
            name: String,
            title: String
          },
          event_types: {
            id: String,
            title: String,
            levels: {
              id: String,
              title: String
            }
          }
        }

        response 200, 'registers the application', 'application/vnd.api+json', data: {
          data: :App
        }
      end
    end
  end
end
