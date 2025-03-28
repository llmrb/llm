# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama: embeddings" do
  let(:ollama) { LLM.ollama(nil, host: "eel.home.network") }

  context "when given a successful response",
          vcr: {cassette_name: "ollama/embeddings/successful_response"} do
    subject(:response) { ollama.embed(["This is a paragraph", "This is another one"]) }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response::Embedding)
    end

    it "returns a model" do
      expect(response.model).to eq("llama3.2")
    end

    it "has embeddings" do
      expect(response.embeddings.size).to eq(2)
    end
  end
end
