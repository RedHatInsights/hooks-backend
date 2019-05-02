# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe FallbackController do
  describe 'handling unknown routes' do
    it 'responds with 404' do
      get :routing_error, params: { path: 'something' }
      expect(response.code).to eq('404')
      expect(response.body).to match('Could not find route /something')
    end
  end
end
