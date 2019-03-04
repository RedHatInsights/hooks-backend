# frozen_string_literal: true

class Level < ApplicationRecord
  belongs_to :event_type
  validates :title, :presence => true
  validates :external_id, :presence => true,
                          :uniqueness => { :scope => :event_type_id }
  has_many :level_filters
  has_many :filters, :through => :level_filters, :inverse_of => :levels
end
