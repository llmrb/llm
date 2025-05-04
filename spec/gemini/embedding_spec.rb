# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI: embeddings" do
  let(:gemini) { LLM.gemini(token) }
  let(:token) { ENV["GEMINI_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "gemini/embeddings/successful_response"} do
    subject(:response) { gemini.embed("Hello, world") }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response::Embedding)
    end

    it "returns a model" do
      expect(response.model).to eq("text-embedding-004")
    end

    it "has embeddings" do
      expect(response.embeddings).to be_instance_of(Array)
    end
  end
end
