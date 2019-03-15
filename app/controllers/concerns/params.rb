# frozen_string_literal: true

require 'base64'

# Imported from RedHatInsights/compliance-backend
#   at commit 6f36a5d1daff8d35b99af348d3f7eddddcf53b1d
#   kudos to dLobatog
module Params
  extend ActiveSupport::Concern

  def endpoint_params(root = params)
    root.require(:endpoint).permit(endpoint_properties)
  end

  def filter_params(root = params)
    root.require(:filter).permit(filter_properties)
  end

  def endpoint_properties
    %i[name url active filter_id]
  end

  def filter_properties
    [:id, :endpoint_id, :app_ids => [], :event_type_ids => [], :level_ids => []]
  end
end
