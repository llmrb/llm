# frozen_string_literal: true

class LLM::OpenAI
  module ResponseParser
    def parse_embedding(raw)
      {
        model: raw["model"],
        embeddings: raw.dig("data").map do |data|
          data["embedding"]
        end,
        prompt_tokens: raw.dig("usage", "prompt_tokens"),
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
        choices: raw["choices"].map do
          mesg = _1["message"]
          logprobs = _1["logprobs"]
          role, content = mesg.values_at("role", "content")
          LLM::Message.new(role, content, {completion: self, logprobs:})
        end,
        prompt_tokens: raw.dig("usage", "prompt_tokens"),
        completion_tokens: raw.dig("usage", "completion_tokens"),
        total_tokens: raw.dig("usage", "total_tokens")
      }
    end
  end
end
