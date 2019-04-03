# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication
  include Params

  class UnknownOrder < RuntimeError; end

  rescue_from Pundit::NotAuthorizedError do
    render json: { errors: 'You are not authorized to access this action.' },
           status: :forbidden
  end

  rescue_from StandardError do |exception|
    render json: { errors: "Server encountered an unexpected error: #{exception.inspect}" },
           status: :internal_server_error
  end

  rescue_from ActiveRecord::SubclassNotFound, UnknownOrder do |exception|
    render_unprocessable_entity exception
  end

  def paginate(scope)
    scope.paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1)
  end

  def order(scope, default_order, allowed_keys)
    if params[:order]
      order, direction = params[:order].split(' ', 2)
      unless valid_sort_order?(order, direction, allowed_keys)
        raise UnknownOrder, "Unknown sort order '#{params[:order]}'"
      end
    end
    scope.order(order || default_order => direction || :asc)
  end

  def process_create(record, serializer_class)
    if record.save
      render :json => serializer_class.new(record), :status => :created
    else
      render_unprocessable_entity record.errors
    end
  end

  def process_update(record, safe_params, serializer_class)
    render_update(record, serializer_class) { |record| record.update(safe_params) }
  end

  def render_update(record, serializer_class)
    if yield record
      render :json => serializer_class.new(record)
    else
      render_unprocessable_entity record.errors
    end
  end

  def process_index(base, serializer_class, opts: {}, default_sort: nil, allowed_sort_keys: [])
    scope = policy_scope(base)
    scope = order(scope, default_sort, allowed_sort_keys) if default_sort
    scope = paginate(scope)
    meta = { :total => scope.count, :per_page => scope.per_page, :page => scope.current_page }
    render :json => serializer_class.new(scope, { :meta => meta }.deep_merge(opts))
  end

  def render_unprocessable_entity(errors)
    render :json => { :errors => errors }, :status => :unprocessable_entity
  end

  private

  def valid_sort_order?(order, direction, allowed_keys)
    (direction.nil? || %w[asc desc].include?(direction.downcase)) && allowed_keys.include?(order)
  end
end
