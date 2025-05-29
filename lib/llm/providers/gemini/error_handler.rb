# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  class ErrorHandler
    ##
    # @return [Net::HTTPResponse]
    #  Non-2XX response from the server
    attr_reader :res

    ##
    # @param [Net::HTTPResponse] res
    #  The response from the server
    # @return [LLM::Gemini::ErrorHandler]
    def initialize(res)
      @res = res
    end

    ##
    # @raise [LLM::Error]
    #  Raises a subclass of {LLM::Error LLM::Error}
    def raise_error!
      case res
      when Net::HTTPBadRequest
        reason = body.dig("error", "details", 0, "reason")
        if reason == "API_KEY_INVALID"
          raise LLM::UnauthorizedError.new { _1.response = res }, "Authentication error"
        else
          raise LLM::ResponseError.new { _1.response = res }, "Unexpected response"
        end
      when Net::HTTPTooManyRequests
        raise LLM::RateLimitError.new { _1.response = res }, "Too many requests"
      else
        raise LLM::ResponseError.new { _1.response = res }, "Unexpected response"
      end
    end

    private

    def body
      @body ||= JSON.parse(res.body)
    end
  end
end
