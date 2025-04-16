# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama: completions" do
  let(:ollama) { LLM.ollama(nil, host: "eel.home.network") }

  context "when given a successful response",
          vcr: {cassette_name: "ollama/completions/successful_response"} do
    subject(:response) { ollama.complete("Hello!", :user) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("llama3.2")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 27,
        completion_tokens: 26,
        total_tokens: 53
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(choice).to have_attributes(
          role: "assistant",
          content: "Hello! It's nice to meet you. Is there something I can help you with, or would you like to chat?"
        )
      end

      it "includes the response" do
        expect(choice.extra[:response]).to eq(response)
      end
    end
  end
end
