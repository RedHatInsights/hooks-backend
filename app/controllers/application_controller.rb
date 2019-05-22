# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication
  include Params
  include PaginationParameters
  include ErrorHandling
  include OpenApi::DSL

  before_action :set_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  def paginate(scope)
    limited_scope = scope.limit(limit_param)

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
    total_records = scope.limit(nil).offset(nil).count
    meta = index_meta(scope, total_records)
    links = index_links(scope, total_records)
    render :json => serializer_class.new(scope, { meta: meta, links: links }.deep_merge(opts))
  end

  def index_meta(scope, total_records)
    meta = {
      :total => total_records
    }
    meta[:limit] = scope.limit_value if scope.respond_to?(:limit_value) && scope.limit_value
    meta[:offset] = scope.offset_value if scope.respond_to?(:offset_value) && scope.offset_value
    meta
  end

  def index_links(_scope, total_records)
    links = {
      first: same_request_with_parameters(first_records_parameters),
      last: same_request_with_parameters(last_records_parameters(total_records))
    }

    add_dynamic_links(links, total_records)

    links
  end

  private

  def add_dynamic_links(links, total_records)
    offset = params[:offset].to_i

    links[:next] = same_request_with_parameters(next_records_parameters) if offset + limit_param < total_records
    links[:previous] = same_request_with_parameters(previous_records_parameters) if offset.positive?
  end

  def valid_sort_order?(order, direction, allowed_keys)
    (direction.nil? || %w[asc desc].include?(direction.downcase)) && allowed_keys.include?(order)
  end

  def same_request_with_parameters(additional_parameters)
    send("#{controller_name}_url", request.query_parameters.merge(additional_parameters))
  end
end
