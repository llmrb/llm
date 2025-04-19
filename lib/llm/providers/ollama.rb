# frozen_string_literal: true

module LLM
  ##
  # The Ollama class implements a provider for
  # [Ollama](https://ollama.ai/)
  class Ollama < Provider
    require_relative "ollama/error_handler"
    require_relative "ollama/response_parser"
    require_relative "ollama/format"
    include Format

    HOST = "localhost"

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, port: 11434, ssl: false, **)
    end

    ##
    # Provides an embedding
    # @param input (see LLM::Provider#embed)
    # @param model (see LLM::Provider#embed)
    # @param params (see LLM::Provider#embed)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#embed)
    def embed(input, model: "llama3.2", **params)
      params   = {model:}.merge!(params)
      req      = Net::HTTP::Post.new("/v1/embeddings", headers)
      req.body = JSON.dump({input:}.merge!(params))
      res      = request(@http, req)
      Response::Embedding.new(res).extend(response_parser)
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-chat-completion Ollama docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @param model (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, model: "llama3.2", **params)
      params   = {model:, stream: false}.merge!(params)
      req      = Net::HTTP::Post.new("/api/chat", headers)
      messages = [*(params.delete(:messages) || []), LLM::Message.new(role, prompt)]
      req.body = JSON.dump({messages: messages.map(&:to_h)}.merge!(params))
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
      @models ||= load_models!("ollama")
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@secret}"
      }
    end

    def response_parser
      LLM::Ollama::ResponseParser
    end

    def error_handler
      LLM::Ollama::ErrorHandler
    end
  end
end
