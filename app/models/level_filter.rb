# frozen_string_literal: true

class LevelFilter < ApplicationRecord
  belongs_to :filter
  belongs_to :level
end
