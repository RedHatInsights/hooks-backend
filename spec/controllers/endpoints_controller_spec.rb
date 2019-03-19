# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EndpointsController, type: :controller do
  describe 'POST #create' do
    it 'fails on wrong type' do
      payload = {
        endpoint: {
          type: 'Foobar'
        }
      }
      request.headers['X-RH-IDENTITY'] = encoded_header

      post :create, params: payload
      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse response.body
      expect(data['errors']).to match(/failed to locate the subclass: 'Foobar'/)
    end
  end
end
