# frozen_string_literal: true

class EventTypeSerializer
  include FastJsonapi::ObjectSerializer

  set_type :event_type
  attributes :name
end
