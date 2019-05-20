# frozen_string_literal: true

require 'base64'

# Imported from RedHatInsights/compliance-backend
#   at commit 6f36a5d1daff8d35b99af348d3f7eddddcf53b1d
#   kudos to dLobatog
module Params
  extend ActiveSupport::Concern

  def endpoint_params(root = params)
    endpoint = root.require(:endpoint)
    endpoint_class = (endpoint[:type] || 'Endpoint').constantize
    data_attributes = endpoint_class.stored_parameters
    endpoint.permit(endpoint_properties + [data: data_attributes])
  rescue NameError
    raise ActiveRecord::SubclassNotFound, "Cannot find an endpoint type: #{endpoint[:type]}"
  end

  def filter_params(root = params, additional_attributes = [])
    root.permit(filter: [filter_properties + additional_attributes])[:filter]
  end

  def endpoint_properties
    %i[name url active filter_id type]
  end

  def filter_properties
    [:id, :endpoint_id, :app_ids => [], :event_type_ids => [], :level_ids => []]
  end
end
