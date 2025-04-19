# frozen_string_literal: true

module LLM
  ##
  # The Gemini class implements a provider for
  # [Gemini](https://ai.google.dev/)
  class Gemini < Provider
    require_relative "gemini/error_handler"
    require_relative "gemini/response_parser"
    require_relative "gemini/format"
    include Format

    HOST = "generativelanguage.googleapis.com"

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, **)
    end

    ##
    # Provides an embedding
    # @param input (see LLM::Provider#embed)
    # @param model (see LLM::Provider#embed)
    # @param params (see LLM::Provider#embed)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#embed)
    def embed(input, model: "text-embedding-004", **params)
      path = ["/v1beta/models/#{model}", "embedContent?key=#{@secret}"].join(":")
      req = Net::HTTP::Post.new(path, headers)
      req.body = JSON.dump({content: {parts: [{text: input}]}})
      res = request(@http, req)
      Response::Embedding.new(res).extend(response_parser)
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://ai.google.dev/api/generate-content#v1beta.models.generateContent Gemini docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @param model (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, model: "gemini-1.5-flash", **params)
      path     = ["/v1beta/models/#{model}", "generateContent?key=#{@secret}"].join(":")
      req      = Net::HTTP::Post.new(path, headers)
      messages = [*(params.delete(:messages) || []), LLM::Message.new(role, prompt)]
      req.body = JSON.dump({contents: format(messages)})
      res      = request(@http, req)
      Response::Completion.new(res).extend(response_parser)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "model"
    end

    ##
    # @return (see LLM::Provider#models)
    def models
      @models ||= load_models!("gemini")
    end

    private

    def headers
      {
        "Content-Type" => "application/json"
      }
    end

    def response_parser
      LLM::Gemini::ResponseParser
    end

    def error_handler
      LLM::Gemini::ErrorHandler
    end
  end
end
