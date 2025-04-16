# frozen_string_literal: true

class LLM::OpenAI
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
        choices: body["choices"].map.with_index do
          extra = {
            index: _2, response: self,
            logprobs: _1["logprobs"]
          }
          LLM::Message.new(*_1["message"].values_at("role", "content"),  extra)
        end,
        prompt_tokens: body.dig("usage", "prompt_tokens"),
        completion_tokens: body.dig("usage", "completion_tokens"),
        total_tokens: body.dig("usage", "total_tokens")
      }
    end

    def parse_output_response(body)
      {
        id: body["id"],
        model: body["model"],
        input_tokens: body.dig("usage", "input_tokens"),
        output_tokens: body.dig("usage", "output_tokens"),
        total_tokens: body.dig("usage", "total_tokens"),
        outputs: body["output"].filter_map.with_index do |output, index|
          next unless output["content"]
          extra = {
            index:, response: self,
            contents: output["content"],
            annotations: output["annotations"]
          }
          LLM::Message.new(output["role"], text(output), extra)
        end
      }
    end

    private

    def text(output)
      output["content"]
        .select { _1["type"] == "output_text" }
        .map { _1["text"] }
        .join("\n")
    end
  end
end
