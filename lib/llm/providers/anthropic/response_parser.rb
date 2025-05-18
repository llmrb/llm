# frozen_string_literal: true

class LLM::Anthropic
  ##
  # @private
  module ResponseParser
    require_relative "response_parser/completion_parser"
    def parse_embedding(body)
      {
        model: body["model"],
        embeddings: body["data"].map { _1["embedding"] },
        total_tokens: body.dig("usage", "total_tokens")
      }
    end

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_completion(body)
      CompletionParser.new(body).format(self)
    end
  end
end
