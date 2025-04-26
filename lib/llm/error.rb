# frozen_string_literal: true

module LLM
  ##
  # The superclass of all LLM errors
  class Error < RuntimeError
    def initialize(...)
      block_given? ? yield(self) : nil
      super
    end

    ##
    # The superclass of all HTTP protocol errors
    class ResponseError < Error
      ##
      # @return [Net::HTTPResponse]
      #  Returns the response associated with an error
      attr_accessor :response
    end

    ##
    # When a prompt is given an object that's not understood
    PromptError = Class.new(Error)

    ##
    # HTTPUnauthorized
    Unauthorized = Class.new(ResponseError)

    ##
    # HTTPTooManyRequests
    RateLimit = Class.new(ResponseError)
  end
end
