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

  describe 'unknown route handling' do
    it 'responds with 404' do
      path = "'a/path/that/does/not/exist"
      assert_recognizes({ controller: 'fallback', action: 'routing_error', path: path },
                        "/#{path}")
    end
  end

  describe 'process_index' do
    controller(AppsController) do
      def index
        base = App.all
        process_index(base, AppSerializer)
      end
    end

    it 'shows a list of items' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      App.delete_all
      FactoryBot.create_list(:app, 11, :with_event_type)

      get :index

      body_json = JSON.parse(response.body)
      expect(body_json['meta']['total']).to eq(11)
      expect(body_json['links']['first']).to match(/offset=0/)
      expect(body_json['links']['last']).to match(/offset=1/)
      expect(response.status).to eq(200)
    end

    it 'limits list of items' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      App.delete_all
      FactoryBot.create_list(:app, 10, :with_event_type)

      get :index, params: { limit: 3, offset: 2 }

      body_json = JSON.parse(response.body)
      expect(body_json['meta']['limit']).to eq(3)
      expect(body_json['meta']['offset']).to eq(2)
      expect(body_json['links']['next']).to match(/limit=3/)
      expect(body_json['links']['next']).to match(/offset=5/)
      expect(body_json['links']['previous']).to match(/limit=2/)
      expect(body_json['links']['previous']).to match(/offset=0/)
      expect(response.status).to eq(200)
    end

    it 'omits next link for last batch' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      App.delete_all
      FactoryBot.create_list(:app, 10, :with_event_type)

      get :index, params: { limit: 3, offset: 8 }

      expect(response.status).to eq(200)
      body_json = JSON.parse(response.body)
      expect(body_json['meta']['limit']).to eq(3)
      expect(body_json['meta']['offset']).to eq(8)
      expect(body_json['links']['next']).to be_nil
      expect(body_json['links']['previous']).to match(/limit=3/)
      expect(body_json['links']['previous']).to match(/offset=5/)
    end

    it 'omits previous link for first batch' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      App.delete_all
      FactoryBot.create_list(:app, 10, :with_event_type)

      get :index, params: { limit: 3, offset: 0 }

      expect(response.status).to eq(200)
      body_json = JSON.parse(response.body)
      expect(body_json['meta']['limit']).to eq(3)
      expect(body_json['meta']['offset']).to eq(0)
      expect(body_json['links']['previous']).to be_nil
      expect(body_json['links']['next']).to match(/limit=3/)
      expect(body_json['links']['next']).to match(/offset=3/)
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
