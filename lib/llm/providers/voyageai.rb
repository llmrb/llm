# frozen_string_literal: true

module LLM
  class VoyageAI < Provider
    require_relative "voyageai/error_handler"
    require_relative "voyageai/response_parser"
    HOST = "api.voyageai.com"

    ##
    # @param key (see LLM::Provider#initialize)
    def initialize(**)
      super(host: HOST, **)
    end

    ##
    # Provides an embedding via VoyageAI per
    # [Anthropic's recommendation](https://docs.anthropic.com/en/docs/build-with-claude/embeddings)
    # @param input (see LLM::Provider#embed)
    # @return (see LLM::Provider#embed)
    def embed(input, model: "voyage-2", **params)
      req = Net::HTTP::Post.new("/v1/embeddings", headers)
      req.body = JSON.dump({input:, model:}.merge!(params))
      res = execute(client: @http, request: req)
      Response::Embedding.new(res).extend(response_parser)
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@key}"
      }
    end

    def response_parser
      LLM::VoyageAI::ResponseParser
    end

    def error_handler
      LLM::VoyageAI::ErrorHandler
    end
  end
end
