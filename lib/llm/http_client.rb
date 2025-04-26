# frozen_string_literal: true

module LLM
  ##
  # @private
  module HTTPClient
    require "net/http"
    ##
    # Initiates a HTTP request
    # @param [Net::HTTP] http
    #  The HTTP object to use for the request
    # @param [Net::HTTPRequest] req
    #  The request to send
    # @param [Proc] b
    #  A block to yield the response to (optional)
    # @return [Net::HTTPResponse]
    #  The response from the server
    # @raise [LLM::Error::Unauthorized]
    #  When authentication fails
    # @raise [LLM::Error::RateLimit]
    #  When the rate limit is exceeded
    # @raise [LLM::Error::ResponseError]
    #  When any other unsuccessful status code is returned
    # @raise [SystemCallError]
    #  When there is a network error at the operating system level
    def request(http, req, &b)
      res = http.request(req, &b)
      case res
      when Net::HTTPOK then res
      else error_handler.new(res).raise_error!
      end
    end
  end
end
