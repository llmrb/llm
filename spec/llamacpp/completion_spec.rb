# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Llamacpp: completions" do
  subject(:llamacpp) { LLM.llamacpp(host:) }
  let(:host) { ENV["LLAMACPP_HOST"] || "localhost" }
  let(:params) { {model: "qwen3"} }

  context "when given a successful response",
          vcr: {cassette_name: "llamacpp/completions/successful_response"} do
    subject(:response) { llamacpp.complete("Hello!", params.merge(role: :user)) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("qwen3")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: instance_of(Integer),
        completion_tokens: instance_of(Integer),
        total_tokens: instance_of(Integer)
      )
    end

    context "when given a message" do
      subject(:message) { response.messages[0] }

      it "returns a message" do
        expect(message).to have_attributes(
          role: "assistant",
          content: /(Hello|Hi|Hey)/i
        )
      end

      it "includes the response" do
        expect(message.extra[:response]).to eq(response)
      end
    end
  end

  context "when given a thread of messages",
          vcr: {cassette_name: "llamacpp/completions/successful_response_thread"} do
    subject(:response) { llamacpp.complete("What is your name? ", role: :user, messages:) }
    let(:messages) { [{role: "system", content: "Your name is John"}] }

    it "returns a message" do
      expect(response).to have_attributes(choices: [have_attributes(role: "assistant", content: /John/i)])
    end
  end
end
