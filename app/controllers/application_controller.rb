# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication

  protect_from_forgery

  rescue_from Pundit::NotAuthorizedError do
    render json: { errors: 'You are not authorized to access this action.' },
           status: :forbidden
  end
end
