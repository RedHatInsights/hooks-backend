# frozen_string_literal: true

class EndpointPolicy < AccountScopedPolicy
  class Scope < ::AccountScopedPolicy::Scope
  end

  def test?
    match_account?
  end
end
