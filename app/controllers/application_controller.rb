# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Pundit
  include Authentication

  rescue_from Pundit::NotAuthorizedError do
    render json: { errors: 'You are not authorized to access this action.' },
           status: :forbidden
  end

  def paginate(scope)
    scope.paginate(:per_page => params[:per_page], :page => params[:page])
  end

  def process_create(record, serializer_class)
    if record.save
      render :json => serializer_class.new(record), :status => :created
    else
      render :json => { :errors => record.errors }, :status => 422
    end
  end

  def process_update(record, safe_params, serializer_class)
    render_update(record, serializer_class) { |record| record.update_attributes(safe_params) }
  end

  def render_update(record, serializer_class)
    if yield record
      render :json => serializer_class.new(record)
    else
      render :json => { :errors => record.errors }, :status => 422
    end
  end
end
