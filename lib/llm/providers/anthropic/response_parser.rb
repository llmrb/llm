# frozen_string_literal: true

class LLM::Anthropic
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
      {
        model: body["model"],
        choices: body["content"].map do
          # TODO: don't hardcode role
          LLM::Message.new("assistant", _1["text"], {response: self})
        end,
        prompt_tokens: body.dig("usage", "input_tokens"),
        completion_tokens: body.dig("usage", "output_tokens")
      }
    end
  end
end
