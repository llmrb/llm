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
        choices: body["candidates"].map.with_index do |c, index|
          role, parts = c["content"]["role"], c["content"]["parts"]
          text  = parts.filter_map { _1["text"] }.join
          funcs = parts.filter_map { _1["functionCall"] }
          extra = {index:, response: self, tool_calls: tool_calls(funcs)}
          LLM::Message.new(role, text, extra)
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
        images: body["candidates"].flat_map do |c|
          parts = c["content"]["parts"]
          parts.filter_map do
            data = _1.dig("inlineData", "data")
            next unless data
            StringIO.new(data.unpack1("m0"))
          end
        end
      }
    end

    def tool_calls(functions)
      return unless functions.any?
      functions.map do
        OpenStruct.from_hash(
          name: _1["name"],
          arguments: _1["args"]
        )
      end
    end
  end
end
