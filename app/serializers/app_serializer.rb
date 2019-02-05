# frozen_string_literal: true

class AppSerializer
  include FastJsonapi::ObjectSerializer

  set_type :app
  attributes :name

  has_many :event_types, :serialize => EventTypeSerializer
end
