# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI: embeddings" do
  let(:openai) { LLM.openai(key:) }
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "openai/embeddings/successful_response"} do
    subject(:response) { openai.embed("Hello, world") }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response)
    end

    it "returns a model" do
      expect(response.model).to eq("text-embedding-3-small")
    end

    it "has embeddings" do
      expect(response.embeddings).to be_instance_of(Array)
    end
  end
end
