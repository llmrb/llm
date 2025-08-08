# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama: embeddings" do
  let(:ollama) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }

  context "when given a successful response",
          vcr: {cassette_name: "ollama/embeddings/successful_response"} do
    subject(:response) { ollama.embed(["This is a paragraph", "This is another one"]) }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response)
    end

    it "returns a model" do
      expect(response.model).to eq("qwen3:latest")
    end

    it "has embeddings" do
      expect(response.embeddings.size).to eq(2)
    end
  end
end
