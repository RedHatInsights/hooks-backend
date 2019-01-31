# frozen_string_literal: true

class EventType < ApplicationRecord
  belongs_to :app

  has_many :event_type_filters, :dependent => :destroy
  has_many :filters, :through => :event_type_filters, :inverse_of => :event_types

  validates :name, :presence => true,
                   :uniqueness => { :scope => :app_id }
end
