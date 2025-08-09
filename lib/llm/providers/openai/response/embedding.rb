# frozen_string_literal: true

module LLM::OpenAI::Response
  module Embedding
    def embeddings = data.map { _1["embedding"] }
    def prompt_tokens = data.dig(0, "usage", "prompt_tokens")
    def total_tokens = data.dig(0, "usage", "total_tokens")
  end
end
