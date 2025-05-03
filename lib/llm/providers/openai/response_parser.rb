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
      CompletionParser.new(body).format(self)
    end

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
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

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_image(body)
      {
        urls: body["data"].filter_map { _1["url"] },
        images: body["data"].filter_map do
          next unless _1["b64_json"]
          StringIO.new(_1["b64_json"].unpack1("m0"))
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
