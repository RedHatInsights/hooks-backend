# frozen_string_literal: true

class LevelSerializer
  include FastJsonapi::ObjectSerializer

  set_type :level
  attributes :title
end
