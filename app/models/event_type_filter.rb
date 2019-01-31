# frozen_string_literal: true

class EventTypeFilter < ApplicationRecord
  belongs_to :event_type

  belongs_to :filter
end
