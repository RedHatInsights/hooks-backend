# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[destroy update]

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    filter = Filter.new(account: current_user.account)
    endpoint = authorize(Endpoint.find(params[:endpoint_id])) if params[:endpoint_id]
    filter.endpoint_filters.build(endpoint: endpoint) if endpoint
    filter = modify_filter(
      filter,
      filter_params[:app_ids],
      filter_params[:event_type_ids],
      filter_params[:level_filters]
    )
    authorize filter
    process_create filter, FilterSerializer
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def index
    process_index index_scope, FilterSerializer
  end

  def destroy
    @filter.destroy!
    head :no_content
  end

  def update
    render_update(@filter, FilterSerializer) do |record|
      modify_filter(
        record,
        filter_params[:app_ids],
        filter_params[:event_type_ids],
        filter_params[:level_filters]
      )
      true
    end
  end

  private

  def modify_filter(filter, app_ids, event_type_ids, levels)
    filter.apps = find_resources(App, app_ids) if app_ids
    filter.event_types = find_resources(EventType, event_type_ids) if event_type_ids
    filter = set_level_filters(filter, levels) if levels
    filter
  end

  def find_resources(klass, ids)
    return klass.none if ids.empty?

    klass.where(:id => ids)
  end

  def set_level_filters(filter, levels)
    return filter if levels.nil?

    existing = filter.level_filters.map(&:level)
    filter.level_filters.where(:level => (existing - levels)).destroy_all
    (levels - existing).each do |to_add|
      filter.level_filters.build(:level => to_add)
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
end
