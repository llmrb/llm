# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  module ResponseParser
    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
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

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_image(body)
      {
        mime_type: body.dig("candidates", 0, "content", "parts", 0, "inlineData", "mimeType").b,
        encoded: body.dig("candidates", 0, "content", "parts", 0, "inlineData", "data").b
      }
    end
  end
end
