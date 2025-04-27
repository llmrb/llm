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
        urls: [],
        images: body["candidates"].flat_map do |candidate|
          candidate["content"]["parts"].filter_map do
            next unless _1.dig("inlineData", "data")
            StringIO.new(_1["inlineData"]["data"].unpack1("m0"))
          end
        end
      }
    end
  end
end
