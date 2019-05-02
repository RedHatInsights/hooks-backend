# frozen_string_literal: true

class FallbackController < ActionController::API
  include ErrorHandling

  def routing_error
    raise ActionController::RoutingError, "/#{params[:path]}"
  end
end
