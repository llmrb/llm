# frozen_string_literal: true

class LLM::Ollama
  ##
  # @private
  module ResponseParser
    require_relative "response_parser/completion_parser"

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_completion(body)
      CompletionParser.new(body).format(self)
    end

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_embedding(body)
      {
        model: body["model"],
        embeddings: body["data"].map { _1["embedding"] },
        prompt_tokens: body.dig("usage", "prompt_tokens"),
        total_tokens: body.dig("usage", "total_tokens")
      }
    end
  end
end
