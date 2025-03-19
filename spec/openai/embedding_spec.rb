# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI: embeddings" do
  let(:openai) { LLM.openai("") }

  before(:each, :success) do
    stub_request(:post, "https://api.openai.com/v1/embeddings")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: fixture("openai/embeddings/hello_world_embedding.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "when given a successful response", :success do
    subject(:response) { openai.embed("Hello, world") }

    it "returns an embedding" do
      expect(response).to be_instance_of(LLM::Response::Embedding)
    end

    it "returns a model" do
      expect(response.model).to eq("text-embedding-3-small")
    end

    it "has embeddings" do
      expect(response.embeddings).to be_instance_of(Array)
    end
  end
end
