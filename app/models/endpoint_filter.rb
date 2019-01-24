class EndpointFilter < ApplicationRecord
  belongs_to :endpoint
  validates_associated :endpoint

  belongs_to :filter
  validates_associated :filter
end
