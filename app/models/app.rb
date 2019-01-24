# frozen_string_literal: true
class App < ApplicationRecord
  validates :name, :uniqueness => true, :presence => true

  has_many :event_types, :dependent => :destroy
end
