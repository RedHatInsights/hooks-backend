class EventType < ApplicationRecord
  belongs_to :app
  validates_associated :app

  validates :name, :presence => true,
                   :uniqueness => { :scope => :app_id }
end
