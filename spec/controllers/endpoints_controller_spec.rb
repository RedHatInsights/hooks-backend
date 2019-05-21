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
      expect(data['errors'].first['detail']).to match(/Cannot find an endpoint type: Foobar/)
    end

    it 'does not allow creation of multiple endpoints with the same name' do
      payload = {
        endpoint: {
          type: '::Endpoints::HttpEndpoint',
          url: 'http://something.somewhere.com',
          name: 'Endpoint'
        }
      }
      request.headers['X-RH-IDENTITY'] = encoded_header

      post :create, params: payload
      expect(response).to have_http_status(:created)

      post :create, params: payload
      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse response.body
      name_error = data['errors'].find { |e| e['source']&.fetch('pointer') == '/data/attributes/name' }
      expect(name_error['detail']).to eq('has already been taken')
    end
  end

  describe 'GET #index' do
    before { request.headers['X-RH-IDENTITY'] = encoded_header }
    let(:active_endpoint) { FactoryBot.create(:http_endpoint, :account => account) }
    let(:inactive_endpoint) { FactoryBot.create(:http_endpoint, :account => account, :active => false) }

    it 'supports limit offset query' do
      get :index, params: { limit: 1, offset: 2 }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['meta']['limit']).to eq(1)
      expect(data['meta']['offset']).to eq(2)
    end

    it 'allows requesting specific sort order with default direction' do
      active_endpoint
      inactive_endpoint
      get :index, params: { order: 'active' }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expected = [inactive_endpoint.id, active_endpoint.id]
      expect(data['data'].map { |h| h['id'].to_i }).to eq(expected)
    end

    it 'allows requesting specific sort order' do
      active_endpoint
      inactive_endpoint
      get :index, params: { order: 'active desc' }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expected = [active_endpoint.id, inactive_endpoint.id]
      expect(data['data'].map { |h| h['id'].to_i }).to eq(expected)
    end

    it 'fails when trying to sort by unsupported column' do
      get :index, params: { order: 'bogus' }
      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse response.body
      expect(data['errors'].first['detail']).to eq("Unknown sort order 'bogus'")
    end
  end
end
# rubocop:enable Metrics/BlockLength
