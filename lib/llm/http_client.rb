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
    # @return [Net::HTTPResponse]
    #  The response from the server
    # @raise [LLM::Error::Unauthorized]
    #  When authentication fails
    # @raise [LLM::Error::RateLimit]
    #  When the rate limit is exceeded
    # @raise [LLM::Error::BadResponse]
    #  When any other unsuccessful status code is returned
    # @raise [SystemCallError]
    #  When there is a network error at the operating system level
    def request(http, req)
      res = http.request(req)
      case res
      when Net::HTTPOK then res
      else error_handler.new(res).raise_error!
      end
    end
  end
end
