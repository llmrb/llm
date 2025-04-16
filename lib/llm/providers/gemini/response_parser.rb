# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  module ResponseParser
    def parse_embedding(body)
      {
        model: "text-embedding-004",
        embeddings: body.dig("embedding", "values")
      }
    end

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_completion(body)
      {
        model: body["modelVersion"],
        choices: body["candidates"].map do
          LLM::Message.new(
            _1.dig("content", "role"),
            _1.dig("content", "parts", 0, "text"),
            {response: self}
          )
        end,
        prompt_tokens: body.dig("usageMetadata", "promptTokenCount"),
        completion_tokens: body.dig("usageMetadata", "candidatesTokenCount")
      }
    end
  end
end
