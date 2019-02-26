# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe ApplicationController do
  describe 'handling general exceptions' do
    controller do
      def index
        raise 'Test exception'
      end
    end

    it 'responds with json error' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      get :index
      expect(response.body).to match(/Test exception/)
    end
  end

  describe 'process_create' do
    controller do
      def index
        model = App.new
        process_create(model, nil)
      end
    end

    it 'responds with errors json on create' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      get :index
      body_json = JSON.parse(response.body)
      expect(body_json['errors']['name']).to include(/can't be blank/)
      expect(response.status).to eq(422)
    end
  end

  describe 'process_update' do
    controller do
      def index
        model = App.new
        process_update(model, { name: nil }, nil)
      end
    end

    it 'responds with errors json on create' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      get :index
      body_json = JSON.parse(response.body)
      expect(body_json['errors']['name']).to include(/can't be blank/)
      expect(response.status).to eq(422)
    end
  end
end
# rubocop:enable Metrics/BlockLength
