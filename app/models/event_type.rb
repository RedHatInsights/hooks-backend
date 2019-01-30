# frozen_string_literal: true

class EventType < ApplicationRecord
  belongs_to :app
  validates_associated :app

  has_many :event_type_filters, :dependent => :destroy
  has_many :filters, :through => :event_type_filters

  validates :name, :presence => true,
                   :uniqueness => { :scope => :app_id }
end
