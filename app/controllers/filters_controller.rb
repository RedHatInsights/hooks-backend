# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[show]

  def show
    render :json => FilterSerializer.new(@filter)
  end

  private

  def find_filter
    @filter = authorize Filter.find_by!(endpoint_id: params.require(:endpoint_id))
  end
end
