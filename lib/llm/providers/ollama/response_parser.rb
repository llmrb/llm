class LLM::Ollama
  module ResponseParser
    ##
    # @param [Hash] raw
    #  The raw response from the LLM provider
    # @return [Hash]
    def parse_completion(raw)
      {
        model: raw["model"],
        choices: [LLM::Message.new(*raw["message"].values_at("role", "content"), {completion: self})],
        prompt_tokens: raw.dig("prompt_eval_count"),
        completion_tokens: raw.dig("eval_count")
      }
    end
  end
end
