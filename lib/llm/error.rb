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

      def message
        [super, response.body].join("\n")
      end
    end

    ##
    # HTTPUnauthorized
    Unauthorized = Class.new(ResponseError)

    ##
    # HTTPTooManyRequests
    RateLimit = Class.new(ResponseError)

    ##
    # When an given an input that is not understood
    FormatError = Class.new(Error)

    ##
    # When given a prompt that is not understood
    PromptError = Class.new(FormatError)
  end
end
