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
    endpoint = Endpoint.new(endpoint_params)
    endpoint.account = current_user.account
    endpoint.type ||= Endpoint.name
    authorize endpoint
    process_create endpoint, EndpointSerializer
  end

  def update
    process_update(@endpoint, endpoint_params, EndpointSerializer)
  end

  private

  def endpoint_params
    params.require(:endpoint).permit(:name, :url, :active)
  end

  def find_endpoint
    @endpoint = authorize Endpoint.find(params[:id])
  end
end
