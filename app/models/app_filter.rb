# frozen_string_literal: true
class AppFilter < ApplicationRecord
  belongs_to :app, :optional => true

  belongs_to :filter
  validates_associated :filter
end
