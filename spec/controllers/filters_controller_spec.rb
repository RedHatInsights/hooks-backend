# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe FiltersController, type: :controller do
  describe 'GET #show' do
    let(:not_found_error) { 'Could not find Filter' }

    before { request.headers['X-RH-IDENTITY'] = encoded_header }
    let(:endpoint) { FactoryBot.create(:http_endpoint, :account => account) }
    let(:filter) { endpoint.create_filter(:account => endpoint.account) }

    it 'returns 404 if the endpoint does not exist' do
      get :show, params: { endpoint_id: endpoint.id + 1 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors']
      expect(error).to eq(not_found_error)
    end

    it 'succeeds if the endpoint exists' do
      filter
      get :show, params: { endpoint_id: endpoint.id }
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['id']).to eq(filter.id.to_s)
      expect(data['attributes']['enabled']).to be_truthy
      relationships = data['relationships']
      expect(relationships['apps']['data']).to eq([])
      expect(relationships['event_types']['data']).to eq([])
      expect(relationships['levels']['data']).to eq([])
      endpoint_data = relationships['endpoint']['data']
      expect(endpoint_data['id']).to eq(endpoint.id.to_s)
      expect(endpoint_data['type']).to eq('endpoint')
    end

    it 'returns 404 if the endpoint exists but does not have a filter' do
      expect(endpoint.filter).to be_nil
      get :show, params: { endpoint_id: endpoint.id }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors']).to eq(not_found_error)
    end

    it 'returns 404 if the endpoint exists but belongs to another user' do
      endpoint = FactoryBot.create(:endpoint, :with_account)

      get :show, params: { endpoint_id: endpoint.id }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors']
      expect(error).to eq(not_found_error)
    end
  end
end
# rubocop:enable Metrics/BlockLength
