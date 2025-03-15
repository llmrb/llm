# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::OpenAI: embeddings" do
  subject(:openai) { LLM.openai("") }

  before(:each, :success) do
    stub_request(:post, "https://api.openai.com/v1/embeddings")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: fixture("hello_world_embedding.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "when given a successful response", :success do
    let(:embedding) { openai.embed("Hello, world") }

    it "returns an embedding" do
      expect(embedding).to be_instance_of(LLM::Response::Embedding)
    end

    it "has model" do
      expect(embedding.model).to eq("text-embedding-3-small")
    end

    it "has embeddings" do
      expect(embedding.embeddings).to be_instance_of(Array)
    end
  end

  def fixture(file)
    File.read File.join(fixtures, file)
  end

  def fixtures
    File.join(__dir__, "..", "fixtures", "responses", "openai", "embeddings")
  end
end
