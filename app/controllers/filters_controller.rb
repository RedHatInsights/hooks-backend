# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[destroy update]

  # rubocop:disable Metrics/AbcSize
  def create
    filter = Filter.new(account: current_user.account)
    endpoint = authorize(Endpoint.find(params[:endpoint_id])) if params[:endpoint_id]
    filter.endpoint_filters.build(endpoint: endpoint) if endpoint
    filter = modify_filter(filter, filter_params[:app_ids], filter_params[:event_type_ids], filter_params[:severity_filters]) # have to make sure this action does everything in-memory
    authorize filter
    process_create filter, FilterSerializer
  end
  # rubocop:enable Metrics/AbcSize

  def index
    records = policy_scope(index_scope)
    render :json => FilterSerializer.new(paginate(records))
  end

  def destroy
    @filter.destroy!
    head :no_content
  end

  def update
    render_update(@filter, FilterSerializer) do |record|
      modify_filter(record, filter_params[:app_ids], filter_params[:event_type_ids], filter_params[:severity_filters])
      true
    end
  end

  private

  def modify_filter(filter, app_ids, event_type_ids, severities)
    filter.apps = find_resources(App, app_ids) if app_ids
    filter.event_types = find_resources(EventType, event_type_ids) if event_type_ids
    filter = set_severity_filters(filter, severities) if severities
    filter
  end

  def find_resources(klass, ids)
    return klass.none if ids.empty?

    klass.where(:id => ids)
  end

  def set_severity_filters(filter, severities)
    return filter if severities.nil?

    existing = filter.severity_filters.map(&:severity)
    filter.severity_filters.where(:severity => (existing - severities)).destroy_all
    (severities - existing).each do |to_add|
      filter.severity_filters.build(:severity => to_add)
    end
    filter
  end

  def find_filter
    @filter = authorize Filter.find(params[:id])
  end

  def index_scope
    if params.key?(:endpoint_id)
      Filter.joins(:endpoint_filters).merge(EndpointFilter.where(:endpoint_id => params[:endpoint_id]))
    else
      Filter
    end
  end

  def filter_params
    params.require(:filter)
  end
end
