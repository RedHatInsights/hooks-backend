class Endpoint < ApplicationRecord
  belongs_to :account
  validates_associated :account

  validates :name, :presence => true
  validates :url, :presence => true
end
