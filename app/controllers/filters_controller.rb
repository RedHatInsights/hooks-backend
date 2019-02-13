# frozen_string_literal: true

class FiltersController < ApplicationController
  def index
    records = policy_scope(index_scope)
    render :json => FilterSerializer.new(paginate(records))
  end

  private

  def index_scope
    if params.key?(:endpoint_id)
      Filter.joins(:endpoints).merge(Endpoint.where(:id => params[:endpoint_id]))
    else
      Filter
    end
  end
end
