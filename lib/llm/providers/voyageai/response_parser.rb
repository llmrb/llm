# frozen_string_literal: true

class LLM::VoyageAI
  module ResponseParser
    def parse_embedding(body)
      {
        model: body["model"],
        embeddings: body["data"].map { _1["embedding"] },
        total_tokens: body.dig("usage", "total_tokens")
      }
    end
  end
end
