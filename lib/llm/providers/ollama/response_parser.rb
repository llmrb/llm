# frozen_string_literal: true

class LLM::Ollama
  module ResponseParser
    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_completion(body)
      {
        model: body["model"],
        choices: [LLM::Message.new(*body["message"].values_at("role", "content"), {completion: self})],
        prompt_tokens: body.dig("prompt_eval_count"),
        completion_tokens: body.dig("eval_count")
      }
    end
  end
end
