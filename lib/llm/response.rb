# frozen_string_literal: true

module LLM
  class Response
    require "json"
    require_relative "response/completion"
    require_relative "response/embedding"
    require_relative "response/output"
    require_relative "response/image"
    require_relative "response/audio"

    ##
    # Returns the response body
    # @return [Hash, String]
    attr_reader :body

    ##
    # @param [Net::HTTPResponse] res
    #  HTTP response
    # @return [LLM::Response]
    #  Returns an instance of LLM::Response
    def initialize(res)
      @res = res
      case res["content-type"]
      when %r|\Aapplication/json\s*| then @body = JSON.parse(res.body)
      else @body = res.body
      end
    end
  end
end
