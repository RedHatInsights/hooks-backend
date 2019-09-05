# frozen_string_literal: true

class EndpointSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :url, :active, :last_delivery_status, :last_delivery_time, :first_failure_time, :type
end
