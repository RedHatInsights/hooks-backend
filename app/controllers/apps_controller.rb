# frozen_string_literal: true

class AppsController < ApplicationController
  def index
    records = paginate(policy_scope(App).includes(:event_types))
    render :json => AppSerializer.new(records, :include => %i[event_types event_types.name])
  end

  def show
    record = authorize App.includes(:event_types).find(params[:id])
    render :json => AppSerializer.new(record, :include => %i[event_types event_types.name])
  end
end
