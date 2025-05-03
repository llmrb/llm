# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  module ResponseParser
    require_relative "response_parser/completion_parser"

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
    def parse_embedding(body)
      {
        model: "text-embedding-004",
        embeddings: body.dig("embedding", "values")
      }
    end

    ##
    # @param [Hash] body
    #  The response body from the LLM provider
    # @return [Hash]
    def parse_image(body)
      {
        urls: [],
        images: body["candidates"].flat_map do |c|
          parts = c["content"]["parts"]
          parts.filter_map do
            data = _1.dig("inlineData", "data")
            next unless data
            StringIO.new(data.unpack1("m0"))
          end
        end
      }
    end
  end
end
