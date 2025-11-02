# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Anthropic: completions" do
  subject(:anthropic) { LLM.anthropic(key:) }
  let(:key) { ENV["ANTHROPIC_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "anthropic/completions/successful_response"} do
    let(:prompt) do
      "Your task is to greet the user. " \
      "Greet the user with 'hello'. " \
      "Nothing else. And do not say 'hi'. "
    end

    subject(:response) do
      anthropic.complete(
        "Hello, world",
        role: :user,
        messages: [{role: :user, content: [{type: :text, text: prompt}]}]
      )
    end

    it "returns a completion" do
      expect(response).to be_a(LLM::Response)
    end

    it "returns a model" do
      expect(response.model).to eq("claude-sonnet-4-20250514")
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

  context "when given an unauthorized response",
          vcr: {cassette_name: "anthropic/completions/unauthorized_response"} do
    subject(:response) { anthropic.complete("Hello", role: :user) }
    let(:key) { "BADTOKEN" }

    it "raises an error" do
      expect { response }.to raise_error(LLM::UnauthorizedError)
    end

    it "includes the response" do
      response
    rescue LLM::UnauthorizedError => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end
end
