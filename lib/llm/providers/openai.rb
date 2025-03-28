# frozen_string_literal: true

module LLM
  ##
  # The OpenAI class implements a provider for
  # [OpenAI](https://platform.openai.com/)
  class OpenAI < Provider
    require_relative "openai/error_handler"
    require_relative "openai/response_parser"
    require_relative "openai/format"
    include Format

    HOST = "api.openai.com"

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, **)
    end

    ##
    # @param input (see LLM::Provider#embed)
    # @return (see LLM::Provider#embed)
    def embed(input, **params)
      req = Net::HTTP::Post.new("/v1/embeddings", headers)
      req.body = JSON.dump({input:, model: "text-embedding-3-small"}.merge!(params))
      res = request(@http, req)
      Response::Embedding.new(res).extend(response_parser)
    end

    ##
    # @see https://platform.openai.com/docs/api-reference/chat/create OpenAI docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, **params)
      params   = {model: "gpt-4o-mini"}.merge!(params)
      req      = Net::HTTP::Post.new("/v1/chat/completions", headers)
      messages = [*(params.delete(:messages) || []), Message.new(role, prompt)]
      req.body = JSON.dump({messages: format(messages)}.merge!(params))
      res      = request(@http, req)
      Response::Completion.new(res).extend(response_parser)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "assistant"
    end

    def models
      @models ||= load_models!("openai")
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@secret}"
      }
    end

    def response_parser
      LLM::OpenAI::ResponseParser
    end

    def error_handler
      LLM::OpenAI::ErrorHandler
    end
  end
end
