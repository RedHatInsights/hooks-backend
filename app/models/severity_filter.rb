class SeverityFilter < ApplicationRecord
  validates :severity, :presence => true

  belongs_to :filter
  validates_associated :filter
end
