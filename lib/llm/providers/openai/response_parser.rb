# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  module ResponseParser
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
    def parse_respond_response(body)
      RespondParser.new(body).format(self)
    end

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
    def parse_image(body)
      {
        urls: body["data"].filter_map { _1["url"] },
        images: body["data"].filter_map do
          next unless _1["b64_json"]
          StringIO.new(_1["b64_json"].unpack1("m0"))
        end
      }
    end
  end
end
