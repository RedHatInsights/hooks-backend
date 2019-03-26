# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
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

  describe 'GET #index' do
    before { request.headers['X-RH-IDENTITY'] = encoded_header }

    it 'supports changing page size' do
      get :index, params: { per_page: 5 }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['meta']['per_page']).to eq(5)
    end

    it 'allows requesting specific page' do
      get :index, params: { page: 1000 }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['meta']['page']).to eq(1000)
    end
  end
end
# rubocop:enable Metrics/BlockLength
