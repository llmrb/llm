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

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, **)
    end

    ##
    # Provides an embedding via VoyageAI per
    # [Anthropic's recommendation](https://docs.anthropic.com/en/docs/build-with-claude/embeddings)
    # @param input (see LLM::Provider#embed)
    # @param [String] token
    #  Valid token for the VoyageAI API
    # @param [String] model
    #  The embedding model to use
    # @param [Hash] params
    #  Other embedding parameters
    # @raise (see LLM::Provider#request)
    # @return (see LLM::Provider#embed)
    def embed(input, token:, model: "voyage-2", **params)
      llm = LLM.voyageai(token)
      llm.embed(input, **params.merge(model:))
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://docs.anthropic.com/en/api/messages Anthropic docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @param model (see LLM::Provider#complete)
    # @param max_tokens The maximum number of tokens to generate
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::Provider#request)
    # @raise [LLM::Error::PromptError]
    #  When given an object a provider does not understand
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, model: "claude-3-5-sonnet-20240620", max_tokens: 1024, **params)
      params   = {max_tokens:, model:}.merge!(params)
      req      = Net::HTTP::Post.new("/v1/messages", headers)
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

    ##
    # @return (see LLM::Provider#models)
    def models
      @models ||= load_models!("anthropic")
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "x-api-key" => @secret,
        "anthropic-version" => "2023-06-01"
      }
    end

    def response_parser
      LLM::Anthropic::ResponseParser
    end

    def error_handler
      LLM::Anthropic::ErrorHandler
    end
  end
end
