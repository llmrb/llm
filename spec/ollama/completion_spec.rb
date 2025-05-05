# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama: completions" do
  let(:ollama) { LLM.ollama(nil, host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }

  context "when given a successful response",
          vcr: {cassette_name: "ollama/completions/successful_response"} do
    let(:prompt) do
      "Your task is to greet the user. " \
      "Greet the user with 'hello'. " \
      "Nothing else. And do not say 'hi'. "
    end
    subject(:response) do
      ollama.complete("Hello!", role: :user, messages: [{role: "system", content: prompt}])
    end

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("llama3.2")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: instance_of(Integer),
        completion_tokens: instance_of(Integer),
        total_tokens: instance_of(Integer)
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(choice).to have_attributes(
          role: "assistant",
          content: /Hello/i
        )
      end

      it "includes the response" do
        expect(choice.extra[:response]).to eq(response)
      end
    end
  end
end
