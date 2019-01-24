# frozen_string_literal: true
class AppFilter < ApplicationRecord
  belongs_to :app
  validates_associated :app

  belongs_to :filter
  validates_associated :filter
end
