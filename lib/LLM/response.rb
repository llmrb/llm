# frozen_string_literal: true

module LLM
  class Response
    attr_accessor :role, :message

    def initialize(role, message)
      @role = role
      @message = message
    end
  end
end
