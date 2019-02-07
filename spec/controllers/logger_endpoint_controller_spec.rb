require 'rails_helper'

RSpec.describe LoggerEndpointController, type: :controller do

  describe "POST #logger" do
    it "returns http success" do
      post 'logger', test: { prop1: 'val1' }
      expect(response).to have_http_status(:success)
    end
  end

end
