# frozen_string_literal: true

class LLM::OpenAI
  module ResponseParser
    def parse_embedding(body)
      {
        model: body["model"],
        embeddings: body.dig("data").map do |data|
          data["embedding"]
        end,
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
        choices: body["choices"].map do
          mesg = _1["message"]
          logprobs = _1["logprobs"]
          role, content = mesg.values_at("role", "content")
          LLM::Message.new(role, content, {completion: self, logprobs:})
        end,
        prompt_tokens: body.dig("usage", "prompt_tokens"),
        completion_tokens: body.dig("usage", "completion_tokens"),
        total_tokens: body.dig("usage", "total_tokens")
      }
    end
  end
end
