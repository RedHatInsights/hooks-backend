# frozen_string_literal: true

module PaginationParameters
  extend ActiveSupport::Concern

  def next_records_parameters
    {
      limit: limit_param,
      offset: params[:offset].to_i + limit_param
    }
  end

  def previous_records_parameters
    offset = params[:offset].to_i if params[:offset]
    limit = limit_param
    {
      limit: offset && offset < limit ? offset : limit,
      offset: [(offset || 0) - limit, 0].max
    }
  end

  def last_records_parameters(total_records)
    {
      offset: [total_records - limit_param, 0].max,
      limit: limit_param
    }
  end

  def first_records_parameters
    {
      offset: 0,
      limit: limit_param
    }
  end

  def limit_param
    params.fetch(:limit, 10).to_i
  end
end
