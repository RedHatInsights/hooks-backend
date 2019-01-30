# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :account
  validates_associated :account

  has_many :endpoint_filters
  has_many :filters, :through => :endpoint_filters, :dependent => :destroy

  validates :name, :presence => true
  validates :url, :presence => true
end
