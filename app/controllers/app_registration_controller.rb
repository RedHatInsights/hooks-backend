# frozen_string_literal: true

class AppRegistrationController < ActionController::API
  include ErrorHandling

  before_action :assert_internal

  def create
    ActiveRecord::Base.transaction do
      app = App.find_or_initialize_by(:name => app_params[:name])
      app.update_attributes!(app_params.slice(:title))
      handle_nested(app.event_types, params[:event_types], :levels)
      render :json => AppSerializer.new(app)
    end
  end

  private

  def assert_internal
    return unless request.headers['X-RH-IDENTITY']

    # If the request has the X-RH-IDENTITY it means it came from the outside world
    #   Requests from inside the platform don't have this header set
    render json: { errors: 'Requests with X-RH-IDENTITY are not allowed to register apps.' },
           status: :forbidden
  end

  def destroy_obsolete(scope, requested_ids)
    scope.where.not(:external_id => requested_ids).destroy_all
  end

  def handle_nested(scope, records_params, sub_key = nil)
    destroy_obsolete(scope, records_params.map { |param| param[:id] })
    records = scope.all
    update_present(records, records_params, sub_key)
    create_missing(scope, records_params, records.map(&:external_id), sub_key)
  end

  def create_missing(scope, records_params, present_ids, sub_key = nil)
    records_params.reject { |param| present_ids.include? param[:id] }.each do |record_params|
      instance = scope.create(inner_params_for(record_params))
      create_missing(instance.public_send(sub_key), record_params.fetch(sub_key, []), []) if sub_key
    end
  end

  def update_present(records, records_params, sub_key)
    records.each do |record|
      record_params = records_params.find { |rp| rp[:id] == record.external_id }
      record.update_attributes(inner_params_for(record_params))
      handle_nested(record.public_send(sub_key), record_params.fetch(sub_key, [])) if sub_key
    end
  end

  def remove_obsolete(scope, wanted_ids)
    scope.where.not(:external_id => wanted_ids).destroy_all
  end

  def inner_params_for(thing)
    thing.permit(:title).slice(:title).merge(:external_id => thing[:id])
  end

  def app_params
    params.require(:application).permit(:name, :title)
  end
end
