# frozen_string_literal: true

class EndpointFilter < ApplicationRecord
  belongs_to :endpoint

  belongs_to :filter
end
