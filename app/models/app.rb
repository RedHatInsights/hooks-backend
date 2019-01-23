class App < ApplicationRecord
  validates :name, :uniqueness => true, :presence => true
end
