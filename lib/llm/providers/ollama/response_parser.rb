# frozen_string_literal: true

class LLM::Ollama
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
        choices: [LLM::Message.new(*body["message"].values_at("role", "content"), {response: self})],
        prompt_tokens: body.dig("prompt_eval_count"),
        completion_tokens: body.dig("eval_count")
      }
    end
  end
end
