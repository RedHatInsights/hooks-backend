# frozen_string_literal: true

class FilterSerializer
  include FastJsonapi::ObjectSerializer

  attributes :enabled

  has_many :apps
  has_many :event_types
  has_many :levels
  has_many :endpoints
end
