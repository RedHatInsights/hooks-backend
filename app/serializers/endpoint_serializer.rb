# frozen_string_literal: true

class EndpointSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :url, :active
end
