
# frozen_string_literal: true

module LLM::Ollama::Response
  module Embedding
    def embeddings = data.map { _1["embedding"] }
    def prompt_tokens = body.dig("usage", "prompt_tokens") || 0
    def total_tokens = body.dig("usage", "total_tokens") || 0
  end
end