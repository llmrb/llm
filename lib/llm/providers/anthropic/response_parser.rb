# frozen_string_literal: true

class LLM::Anthropic
  module ResponseParser
    def parse_embedding(raw)
      {
        model: raw["model"],
        embeddings: raw.dig("data").map do |data|
          data["embedding"]
        end,
        total_tokens: raw.dig("usage", "total_tokens")
      }
    end

    ##
    # @param [Hash] raw
    #  The raw response from the LLM provider
    # @return [Hash]
    def parse_completion(raw)
      {
        model: raw["model"],
        choices: raw["content"].map do
          # TODO: don't hardcode role
          LLM::Message.new("assistant", _1["text"], {completion: self})
        end,
        prompt_tokens: raw.dig("usage", "input_tokens"),
        completion_tokens: raw.dig("usage", "output_tokens")
      }
    end
  end
end
