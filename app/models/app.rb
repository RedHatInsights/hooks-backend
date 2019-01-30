# frozen_string_literal: true

class App < ApplicationRecord
  validates :name, :uniqueness => true, :presence => true

  has_many :event_types, :dependent => :destroy

  has_many :app_filters, :dependent => :destroy
  has_many :filters, :through => :app_filters
end
