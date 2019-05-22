# frozen_string_literal: true

class EndpointsController < ApplicationController
  include Documentation::Endpoints

  before_action :find_endpoint, :only => %i[destroy show update test]

  ALLOWED_SORT_KEYS = %w[name url active].freeze

  def index
    process_index Endpoint, EndpointSerializer,
                  default_sort: 'name', allowed_sort_keys: ALLOWED_SORT_KEYS
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
    rescue ActiveRecord::RecordNotFound => e
      render_unprocessable_entity e
      return
    end

    authorize endpoint
    process_create endpoint, EndpointSerializer
  end

  def update
    full_params = endpoint_params.merge(transform_filter_params)
    process_update(@endpoint, full_params, EndpointSerializer)
  end

  def test
    SendNotificationJob.perform_now(@endpoint, Time.zone.now, 'Test', 'Test message from webhooks')
    head :no_content
  end

  private

  def find_endpoint
    @endpoint = authorize(Endpoint.includes(:filter).find(params[:id]))
  end

  def nested_filter
    filter_params(params.require(:endpoint), [:_destroy])
  end

  def build_filter_attributes(filter_params)
    filter_params.merge(account: current_user.account)
  end

  def build_endpoint
    endpoint = Endpoint.new(endpoint_params)
    endpoint.account = current_user.account
    endpoint.type ||= Endpoint.name

    authorize(endpoint.build_filter(build_filter_attributes(nested_filter))) if nested_filter

    endpoint
  end

  def transform_filter_params
    return {} unless nested_filter

    {
      filter_attributes: build_filter_attributes(nested_filter)
    }
  end
end
