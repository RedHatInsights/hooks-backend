# frozen_string_literal: true
class SeverityFilter < ApplicationRecord
  belongs_to :filter
  validates_associated :filter
end
