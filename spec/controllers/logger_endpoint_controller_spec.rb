# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoggerEndpointController, type: :controller do
  describe 'POST #logger' do
    it 'returns http success' do
      payload = {
        test: {
          prop1: 'val1'
        }
      }
      post :create, params: payload
      expect(response).to have_http_status(:success)
    end
  end
end
