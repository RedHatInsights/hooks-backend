# frozen_string_literal: true

class EndpointsController < ApplicationController
  before_action :find_endpoint, :only => %i[destroy show update]

  def index
    records = paginate(policy_scope(Endpoint))
    render :json => EndpointSerializer.new(records)
  end

  def show
    render :json => EndpointSerializer.new(@endpoint)
  end

  def destroy
    @endpoint.destroy!
    head :no_content
  end

  def create
    begin
      endpoint = build_endpoint
    rescue ActiveRecord::RecordNotFound => ex
      render_unprocessable_entity ex
      return
    end

    authorize endpoint
    process_create endpoint, EndpointSerializer
  end

  def update
    process_update(@endpoint, endpoint_params, EndpointSerializer)
  end

  private

  def find_endpoint
    @endpoint = authorize Endpoint.find(params[:id])
  end

  def nested_filters
    params.require(:endpoint).permit(filters: [filter_properties]).fetch(:filters, [])
  end

  def build_filter_attributes(filter_params)
    attributes = filter_params.merge(filter_params.merge(account: current_user.account))
    attributes
  end

  def build_endpoint
    endpoint = Endpoint.new(endpoint_params)
    endpoint.account = current_user.account
    endpoint.type ||= Endpoint.name

    nested_filters.each do |filter_params|
      authorize(endpoint.filters.build(build_filter_attributes(filter_params)))
    end
    endpoint
  end
end
