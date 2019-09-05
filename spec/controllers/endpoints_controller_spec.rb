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

    it 'creates HTTP endpoint if no type is given and URL is http' do
      payload = { endpoint: { url: 'http://something.somwehere.com', name: 'Default HTTP' } }
      request.headers['X-RH-IDENTITY'] = encoded_header
      post :create, params: payload

      data = JSON.parse response.body
      expect(data['data']['attributes']['type']).to eq(Endpoints::HttpEndpoint.name)
    end

    it 'creates HTTP endpoint if no type is given and URL is https' do
      payload = { endpoint: { url: 'https://something.somwehere.com', name: 'Default HTTPS' } }
      request.headers['X-RH-IDENTITY'] = encoded_header
      post :create, params: payload

      data = JSON.parse response.body
      expect(data['data']['attributes']['type']).to eq(Endpoints::HttpsEndpoint.name)
    end
  end

  describe 'POST #update' do
    before { request.headers['X-RH-IDENTITY'] = encoded_header }
    let(:https_endpoint) { FactoryBot.create(:https_endpoint, :with_certificate, :account => account) }

    it 'changes endpoint type when scheme changes' do
      original_payload = { endpoint: { url: https_endpoint.url, data: https_endpoint.data } }
      payload = { endpoint: { url: https_endpoint.url.sub('https', 'http'), data: https_endpoint.data } }

      put :update, params: payload.merge(id: https_endpoint.id)
      data = JSON.parse response.body
      expect(data['data']['attributes']['type']).to eq(Endpoints::HttpEndpoint.name)

      put :update, params: original_payload.merge(id: https_endpoint.id)
      data = JSON.parse response.body
      expect(data['data']['attributes']['type']).to eq(Endpoints::HttpsEndpoint.name)
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

    it 'fails to search with unknown field' do
      get :index, params: { q: 'test_field~test_val' }
      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse response.body
      expect(data['errors'].first['detail']).to eq('test_field is not marked searchable')
    end

    it 'fails to search with bad query' do
      get :index, params: { q: 'test,bleh' }
      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse response.body
      expect(data['errors'].first['detail']).to eq('test is not valid search codition, should be field~value')
    end

    it 'searches by url' do
      good = FactoryBot.create(:http_endpoint, :account => account, url: 'http://good.com')
      FactoryBot.create(:http_endpoint, :account => account, url: 'http://bad.com')
      get :index, params: { q: 'url~good' }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['data'].map { |h| h['id'].to_i }).to eq([good.id])
    end

    it 'searches by name' do
      good = FactoryBot.create(:http_endpoint, :account => account, name: 'test_good_name')
      FactoryBot.create(:http_endpoint, :account => account, name: 'test_bad_name')
      get :index, params: { q: 'name~good' }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['data'].map { |h| h['id'].to_i }).to eq([good.id])
    end

    it 'searches by both name and url' do
      good_name = FactoryBot.create(:http_endpoint, :account => account, name: 'test_good_name')
      FactoryBot.create(:http_endpoint, :account => account, name: 'test_bad_name')
      good_url = FactoryBot.create(:http_endpoint, :account => account, url: 'http://test_good_url.example.com')
      FactoryBot.create(:http_endpoint, :account => account, url: 'http://test_bad_url.example.com')
      get :index, params: { q: 'good' }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['data'].map { |h| h['id'].to_i }).to match_array([good_name.id, good_url.id])
    end
  end
end
# rubocop:enable Metrics/BlockLength
