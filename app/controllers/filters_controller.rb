# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[destroy]

  def index
    records = policy_scope(index_scope)
    render :json => FilterSerializer.new(paginate(records))
  end

  def destroy
    @filter.destroy!
    head :no_content
  end

  private

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
