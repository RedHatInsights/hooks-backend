# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication
  include Params

  class UnknownOrder < RuntimeError; end
  class BadRequest < RuntimeError; end

  rescue_from Pundit::NotAuthorizedError do
    render json: { errors: 'You are not authorized to access this action.' },
           status: :forbidden
  end

  rescue_from StandardError do |exception|
    render json: { errors: "Server encountered an unexpected error: #{exception.inspect}" },
           status: :internal_server_error
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

  def paginate(scope)
    raise BadRequest, 'Both page and offset pagination is not allowed' if page_pagination? && offset_pagination?

    limit_query(scope.paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1))
  end

  def page_pagination?
    params[:per_page] || params[:page]
  end

  def offset_pagination?
    params[:limit] || params[:offset]
  end

  def limit_query(scope)
    limited_scope = scope
    if params[:limit]
      limit = params[:limit].to_i
      limited_scope = limited_scope.limit(limit)
    end

    if params[:offset]
      offset = params[:offset].to_i
      limited_scope = limited_scope.offset(offset)
    end
    limited_scope
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
    meta = index_meta(scope)
    render :json => serializer_class.new(scope, { :meta => meta }.deep_merge(opts))
  end

  def index_meta(scope)
    meta = {
      :total => scope.count,
      :per_page => scope.per_page,
      :page => scope.current_page
    }
    meta[:limit] = scope.limit_value if scope.respond_to?(:limit_value)
    meta[:offset] = scope.offset_value if scope.respond_to?(:offset_value)
    meta
  end

  def render_unprocessable_entity(errors)
    render :json => { :errors => errors }, :status => :unprocessable_entity
  end

  def render_not_found(what, id)
    message = "Could not find #{what}"
    message += "with 'id'=#{id}" if id
    render :json => { :errors => message }, :status => :not_found
  end

  private

  def valid_sort_order?(order, direction, allowed_keys)
    (direction.nil? || %w[asc desc].include?(direction.downcase)) && allowed_keys.include?(order)
  end
end
# rubocop:enable Metrics/ClassLength
