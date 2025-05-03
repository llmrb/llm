# frozen_string_literal: true

class LLM::Anthropic
  ##
  # @private
  module ResponseParser
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
      parts = body["content"]
      texts = parts.select { _1["type"] == "text" }
      tools = parts.select { _1["type"] == "tool_use" }
      {

        model: body["model"],
        choices: texts.map.with_index do
          extra = {index: _2, response: self, tool_calls: tool_calls(tools)}
          LLM::Message.new(body["role"], _1["text"], extra)
        end,
        prompt_tokens: body.dig("usage", "input_tokens"),
        completion_tokens: body.dig("usage", "output_tokens")
      }
    end

    private

    def tool_calls(tools)
      return [] unless tools
      tools.filter_map do |tool|
        OpenStruct.new(
          id: tool["id"],
          name: tool["name"],
          arguments: tool["input"]
        )
      end
    end
  end
end
