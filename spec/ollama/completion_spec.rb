# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::Ollama: completions" do
  subject(:ollama) { LLM.ollama("") }

  before(:each, :success) do
    stub_request(:post, "localhost:11434/api/chat")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: fixture("ollama/completions/ok_completion.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "when given a successful response", :success do
    subject(:response) { ollama.complete("Hello!", :user) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("llama3.2")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 26,
        completion_tokens: 298,
        total_tokens: 324
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(choice).to have_attributes(
          role: "assistant",
          content: "Hello! How are you today?"
        )
      end

      it "includes the response" do
        expect(choice.extra[:completion]).to eq(response)
      end
    end
  end
end
