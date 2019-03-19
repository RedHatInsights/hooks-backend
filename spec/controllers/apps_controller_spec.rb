# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppsController do
  let(:example_app) { FactoryBot.create(:app, :with_event_type) }
  setup do
    example_app.save!
    request.headers['X-RH-IDENTITY'] = encoded_header
  end

  describe 'apps index' do
    it 'returns a list of apps' do
      get :index
      expect(parsed_response['data'].class).to eq(Array)
      expect(parsed_response['data'][0]['type']).to eq('app')
    end

    it 'includes event types' do
      get :index

      event_types = parsed_response['included'].keep_if { |included| included['type'] == 'event_type' }
      expect(event_types).to_not be_empty
    end

    it 'includes levels' do
      get :index

      levels = parsed_response['included'].keep_if { |included| included['type'] == 'level' }
      expect(levels).to_not be_empty
    end
  end

  private

  def parsed_response
    JSON.parse(response.body)
  end
end
# rubocop:enable Metrics/BlockLength
