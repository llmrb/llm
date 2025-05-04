# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Anthropic: embeddings" do
  let(:anthropic) { LLM.anthropic(token) }
  let(:token) { ENV["VOYAGEAI_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "anthropic/embeddings/successful_response"} do
    subject(:response) { anthropic.embed("Hello, world", token:) }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response::Embedding)
    end

    it "returns a model" do
      expect(response.model).to eq("voyage-2")
    end

    it "has embeddings" do
      expect(response.embeddings).to be_instance_of(Array)
    end
  end
end
