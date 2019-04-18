# frozen_string_literal: true

module Notifications
  INCOMING_TOPIC = 'hooks.outbox'

  class ExternalError < RuntimeError
    def initialize(cause)
      message = case cause
                when Exception
                  "Caught exception: #{cause}"
                when String
                  cause
                end
      super(message)
    end
  end

  class RecoverableError < ExternalError
  end

  class FatalError < ExternalError
  end
end
