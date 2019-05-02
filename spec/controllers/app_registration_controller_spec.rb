# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppRegistrationController do
  before do
    App.destroy_all
  end

  describe 'app registration' do
    let(:levels) do
      [{ :id => 'application.event_type.2.level.1',
         :title => 'Low' },
       { :id => 'application.event_type.2.level.2',
         :title => 'Medium' }]
    end

    let(:event_types) do
      [{ :id => 'application.event_type.1',
         :title => 'Something happened',
         :levels => [] },
       { :id => 'application.event_type.2',
         :title => 'Something else happened',
         :levels => levels }]
    end

    let(:create_params) do
      { :application =>
        { :title => 'Application',
          :name => 'application' },
        :event_types => event_types }
    end

    # rubocop:disable Metrics/AbcSize
    def assert_nested_matches_params(scope, params, sub_key = nil)
      expect(scope.count).to eq(params.count)
      params.each do |record_params|
        record = scope.where(:external_id => record_params[:id]).first
        expect(record.title).to eq(record_params[:title])
        assert_nested_matches_params(record.public_send(sub_key), record_params[sub_key]) if sub_key
      end
    end
    # rubocop:enable Metrics/AbcSize

    def assert_app_matches_params(app, params)
      app_params = params[:application]
      expect(app.name).to eq(app_params[:name])
      expect(app.title).to eq(app_params[:title])
      assert_nested_matches_params(app.event_types, params[:event_types], :levels)
    end

    def register_app!
      post :create, :params => create_params
      expect(response.code).to eq('200')
    end

    it 'creates an application with event types and levels' do
      register_app!
      data = JSON.parse(response.body)['data']
      app = App.find(data['id'])
      assert_app_matches_params(app.reload, create_params)
    end

    it 'removes obsolete event types and their levels' do
      app = Builder::App.build! do |app|
        app.name 'application'
        app.event_type('application.event_type.3').level 'interesting'
      end

      register_app!
      expect(EventType.where(:external_id => 'application.event_type.3')).to be_empty
      expect(Level.where(:external_id => 'interesting')).to be_empty
      assert_app_matches_params(app.reload, create_params)
    end

    it 'removes obsolete levels' do
      app = Builder::App.build! do |app|
        app.name 'application'
        app.event_type('application.event_type.2')
           .levels %w[interesting application.event_type.2.level.1]
      end
      id = app.event_types.first.id

      register_app!
      expect(Level.where(:external_id => 'interesting')).to be_empty
      expect(app.event_types.where(:external_id => 'application.event_type.2').first.id).to eq(id)
      assert_app_matches_params(app.reload, create_params)
    end

    it 'updates the application title' do
      app = Builder::App.build! do |app|
        app.name 'application'
        app.event_type('application.event_type.2').level 'interesting'
      end

      register_app!
      expect(app.reload.title).to eq('Application')
      assert_app_matches_params(app, create_params)
    end

    it '404s if the X-RH-IDENTITY header is set' do
      request.headers['X-RH-IDENTITY'] = encoded_header
      post :create, :params => create_params
      expect(response.code).to eq('403')
      data = JSON.parse(response.body)
      expect(data['errors']).to eq('Requests with X-RH-IDENTITY are not allowed to register apps.')
    end
  end
end
# rubocop:enable Metrics/BlockLength
