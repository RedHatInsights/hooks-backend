# frozen_string_literal: true

class AppPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end
end
