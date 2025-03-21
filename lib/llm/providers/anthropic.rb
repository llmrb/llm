# frozen_string_literal: true

module LLM
  ##
  # The Anthropic class implements a provider for
  # [Anthropic](https://www.anthropic.com)
  class Anthropic < Provider
    require_relative "anthropic/error_handler"
    require_relative "anthropic/response_parser"
    require_relative "anthropic/format"
    include Format

    HOST = "api.anthropic.com"
    DEFAULT_PARAMS = {max_tokens: 1024, model: "claude-3-5-sonnet-20240620"}.freeze

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, **)
    end

    ##
    # @param input (see LLM::Provider#embed)
    # @return (see LLM::Provider#embed)
    def embed(input, **params)
      req = Net::HTTP::Post.new ["api.voyageai.com/v1", "embeddings"].join("/")
      body = {input:, model: "voyage-2"}.merge!(params)
      req = preflight(req, body)
      res = request(@http, req)
      Response::Embedding.new(res).extend(response_parser)
    end

    ##
    # @see https://docs.anthropic.com/en/api/messages Anthropic docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, **params)
      req = Net::HTTP::Post.new ["/v1", "messages"].join("/")
      messages = [*(params.delete(:messages) || []), Message.new(role, prompt)]
      params = DEFAULT_PARAMS.merge(params)
      body = {messages: format(messages)}.merge!(params)
      req = preflight(req, body)
      res = request(@http, req)
      Response::Completion.new(res).extend(response_parser)
    end

    private

    def auth(req)
      req["anthropic-version"] = "2023-06-01"
      req["x-api-key"] = @secret
    end

    def response_parser
      LLM::Anthropic::ResponseParser
    end

    def error_handler
      LLM::Anthropic::ErrorHandler
    end
  end
end
