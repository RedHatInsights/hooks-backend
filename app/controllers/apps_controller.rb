class AppsController < ApplicationController
  def index
    records = paginate(policy_scope(App).includes(:event_types))
    render :json => AppSerializer.new(records, :include => [:event_types, :'event_types.name'])
  end

  def show
    record = authorize App.find(params[:id]).includes(:event_types)
    render :json => AppSerializer.new(record, :include => [:event_types, :'event_types.name'])
  end
end
