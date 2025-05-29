# frozen_string_literal: true

class LLM::VoyageAI
  class ErrorHandler
    ##
    # @return [Net::HTTPResponse]
    #  Non-2XX response from the server
    attr_reader :res

    ##
    # @param [Net::HTTPResponse] res
    #  The response from the server
    # @return [LLM::OpenAI::ErrorHandler]
    def initialize(res)
      @res = res
    end

    ##
    # @raise [LLM::Error]
    #  Raises a subclass of {LLM::Error LLM::Error}
    def raise_error!
      case res
      when Net::HTTPUnauthorized
        raise LLM::UnauthorizedError.new { _1.response = res }, "Authentication error"
      when Net::HTTPTooManyRequests
        raise LLM::RateLimitError.new { _1.response = res }, "Too many requests"
      else
        raise LLM::ResponseError.new { _1.response = res }, "Unexpected response"
      end
    end
  end
end
