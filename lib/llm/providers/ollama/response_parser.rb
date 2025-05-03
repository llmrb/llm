# frozen_string_literal: true

class LLM::Ollama
  ##
  # @private
  module ResponseParser
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

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_completion(body)
      {
        model: body["model"],
        choices: [begin
          role, content, calls = body["message"].values_at("role", "content", "tool_calls")
          extra = {response: self, tool_calls: tool_calls(calls)}
          LLM::Message.new(role, content, extra)
        end],
        prompt_tokens: body.dig("prompt_eval_count"),
        completion_tokens: body.dig("eval_count")
      }
    end

    private

    def tool_calls(tools)
      return [] unless tools
      tools.filter_map do |tool|
        next unless tool["function"]
        OpenStruct.new(tool["function"])
      end
    end
  end
end
