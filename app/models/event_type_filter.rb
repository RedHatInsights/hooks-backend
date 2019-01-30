# frozen_string_literal: true

class EventTypeFilter < ApplicationRecord
  belongs_to :event_type, :optional => true

  belongs_to :filter
  validates_associated :filter
end
