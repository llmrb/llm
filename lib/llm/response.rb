# frozen_string_literal: true

module LLM
  class Response
    require "json"
    require_relative "response/completion"
    require_relative "response/embedding"
    require_relative "response/output"
    require_relative "response/image"

    ##
    # @return [Hash]
    #  Returns the response body
    attr_reader :body

    ##
    # @param [Net::HTTPResponse] res
    #  HTTP response
    # @return [LLM::Response]
    #  Returns an instance of LLM::Response
    def initialize(res)
      @res = res
      @body = JSON.parse(res.body)
    end
  end
end
