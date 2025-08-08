# frozen_string_literal: true

module LLM::Gemini::Response
  module Embedding
    def model = "text-embedding-004"
    def embeddings = body.dig("embedding", "values")
  end
end