# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :account

  has_many :endpoint_filters, :dependent => :destroy
  has_many :filters, :through => :endpoint_filters, :dependent => :destroy, :inverse_of => :endpoints

  validates :name, :presence => true
  validates :url, :presence => true
end
