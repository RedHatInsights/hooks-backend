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
    if endpoint.save
      render :json => EndpointSerializer.new(endpoint), :status => :created
    else
      render :json => { :errors => endpoint.errors }, :status => 422
    end
  end

  def update
    if @endpoint.update_attributes(endpoint_params)
      render :json => EndpointSerializer.new(@endpoint)
    else
      render :json => { :errors => @endpoint.errors }, :status => 422
    end
  end

  private

  def endpoint_params
    params.require(:endpoint).permit(:name, :url, :active)
  end

  def find_endpoint
    @endpoint = authorize Endpoint.find(params[:id])
  end
end
