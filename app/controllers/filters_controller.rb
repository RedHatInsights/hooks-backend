# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[destroy update]

  # rubocop:disable Metrics/AbcSize
  def create
    filter = Filter.new(:account => current_user.account)
    authorize filter
    filter.endpoints << authorize(Endpoint.find(params[:endpoint_id])) if params[:endpoint_id]
    base = params[:filter]
    filter = modify_filter(filter, base[:app_ids], base[:event_type_ids], base[:severity_filters])
    if filter.save
      render :json => FilterSerializer.new(filter), :status => :created
    else
      render :json => { :errors => filter.errors }, :status => 422
    end
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
    base = params[:filter]
    modify_filter(@filter, base[:app_ids], base[:event_type_ids], base[:severity_filters])
  end

  private

  def modify_filter(filter, app_ids, event_type_ids, severities)
    filter.apps = find_resources(App, app_ids) if app_ids
    filter.event_types = find_resources(EventType, event_type_ids) if event_type_ids
    filter = set_severity_filters(filter, severities) if severities
    filter
  end

  def find_resources(klass, ids)
    return [] if ids.empty?

    klass.where(:id => ids)
  end

  def set_severity_filters(filter, severities)
    return filter if severities.nil?

    existing = filter.severity_filters.map(&:severity)
    filter.severity_filters.where(:severity => (existing - severities)).destroy_all
    (severities - existing).each do |to_add|
      filter.severity_filters << SeverityFilter.new(:severity => to_add)
    end
    filter
  end

  def find_filter
    @filter = authorize Filter.find(params[:id])
  end

  def index_scope
    if params.key?(:endpoint_id)
      Filter.joins(:endpoints).merge(Endpoint.where(:id => params[:endpoint_id]))
    else
      Filter
    end
  end
end
