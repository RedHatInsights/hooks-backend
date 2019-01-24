# frozen_string_literal: true
class App < ApplicationRecord
  validates :name, :uniqueness => true, :presence => true
end
