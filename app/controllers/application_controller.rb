# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication
  include Params

  rescue_from Pundit::NotAuthorizedError do
    render json: { errors: 'You are not authorized to access this action.' },
           status: :forbidden
  end

  rescue_from StandardError do |exception|
    render json: { errors: "Server encountered an unexpected error: #{exception.inspect}" },
           status: :internal_server_error
  end

  def paginate(scope)
    scope.paginate(:per_page => params[:per_page], :page => params[:page])
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

  def render_unprocessable_entity(errors)
    render :json => { :errors => errors }, :status => :unprocessable_entity
  end
end
