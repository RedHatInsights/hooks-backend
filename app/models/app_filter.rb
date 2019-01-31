# frozen_string_literal: true

class AppFilter < ApplicationRecord
  belongs_to :app

  belongs_to :filter
end
