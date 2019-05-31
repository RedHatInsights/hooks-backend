# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    class UnknownOrder < RuntimeError; end
    class BadRequest < RuntimeError; end

    rescue_from StandardError do |exception|
      render :json => exception_hash(
        exception,
        status: :internal_server_error,
        detail: 'Server encountered an unexpected error'
      ), status: :internal_server_error
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
      render :json => exception_hash(
        exception,
        status: :bad_request,
        detail: 'Server cannot accept given parameters'
      ), status: :bad_request
    end

    rescue_from ActiveRecord::SubclassNotFound, UnknownOrder do |exception|
      render_unprocessable_entity exception
    end
  end
  # rubocop:enable Metrics/BlockLength

  def render_unprocessable_entity(errors)
    errors_arr = case errors
                 when Exception
                   [exception_hash(errors, status: :unprocessable_entity)]
                 when ActiveModel::Errors
                   model_errors_hash(errors)
                 end

    errors_hash = errors_arr.inject({}) do |hash, error_hash|
      hash.deep_merge(error_hash) { |_k, v1, v2| v1 + v2 }
    end
    render :json => errors_hash, status: :unprocessable_entity
  end

  def model_errors_hash(errors)
    errors.messages.map do |field, messages|
      messages.map do |message|
        single_error_hash(
          detail: message,
          source: { pointer: "/data/attributes/#{field}" },
          status: :unprocessable_entity
        )
      end
    end.flatten
  end

  def exception_hash(
    exception,
    status:,
    detail: exception.message,
    title: exception.class.to_s,
    source: nil
  )
    single_error_hash(
      title: title,
      detail: detail,
      source: source,
      status: status
    )
  end

  def render_not_found(what, id, options: {})
    message = "Could not find #{what}"
    message += "with 'id'=#{id}" if id
    render :json => single_error_hash(
      status: :not_found,
      title: 'Record not found',
      detail: message,
      options: options
    ), status: :not_found
  end

  # rubocop:disable Metrics/MethodLength
  def single_error_hash(status: nil, title: nil, detail: nil, source: nil, options: {})
    if source.is_a?(Hash) && !source.key?(:pointer) && !source.key?(:parameter)
      raise ArgumentException, 'source should have either pointer or parameter key'
    end

    options.deep_merge(
      errors: [
        {
          status: status,
          title: title,
          detail: detail,
          source: source
        }.compact
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength
end
