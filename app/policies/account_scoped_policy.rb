# frozen_string_literal: true

class AccountScopedPolicy < ApplicationPolicy
  def index?
    match_account?
  end

  def show?
    match_account?
  end

  def create?
    valid_user?
  end

  def update?
    match_account?
  end

  def destroy?
    match_account?
  end

  class Scope < ::ApplicationPolicy::Scope
    def resolve
      only_matching_account
    end
  end
end
