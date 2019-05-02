# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    class UnknownOrder < RuntimeError; end
    class BadRequest < RuntimeError; end

    rescue_from StandardError do |exception|
      render json: { errors: "Server encountered an unexpected error: #{exception.inspect}" },
             status: :internal_server_error
    end

    rescue_from ActionController::RoutingError do |exception|
      render_not_found("route #{exception.message}", nil)
    end

    # If a client is not authorized to see an object, the application SHOULD NOT
    # allow the unauthorized client to determine the existence or non-existence of
    # an object
    rescue_from Pundit::NotAuthorizedError do |exception|
      render_not_found(exception.record.class, exception.record.id)
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render_not_found(exception.model, exception.id)
    end

    rescue_from BadRequest do |exception|
      render json: { errors: "Server cannot accept given parameters, reason: #{exception.inspect}" },
             status: :bad_request
    end

    rescue_from ActiveRecord::SubclassNotFound, UnknownOrder do |exception|
      render_unprocessable_entity exception
    end
  end

  def render_unprocessable_entity(errors)
    render :json => { :errors => errors }, :status => :unprocessable_entity
  end

  def render_not_found(what, id)
    message = "Could not find #{what}"
    message += "with 'id'=#{id}" if id
    render :json => { :errors => message }, :status => :not_found
  end
end
