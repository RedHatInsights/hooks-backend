class EventTypeFilter < ApplicationRecord
  belongs_to :event_type
  validates_associated :event_type
  belongs_to :filter
  validates_associated :filter
end