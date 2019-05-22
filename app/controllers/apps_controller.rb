# frozen_string_literal: true

class AppsController < ApplicationController
  include Documentation::Apps

  def index
    process_index App.includes(:event_types), AppSerializer,
                  :opts => { :include => default_includes }
  end

  def show
    record = authorize App.includes(:event_types).find(params[:id])
    render :json => AppSerializer.new(record, :include => default_includes)
  end

  private

  def default_includes
    %i[event_types event_types.external_id event_types.levels]
  end
end
