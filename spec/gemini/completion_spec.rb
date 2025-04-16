# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini: completions" do
  subject(:gemini) { LLM.gemini(token) }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "gemini/completions/successful_response"} do
    subject(:response) { gemini.complete("Hello!", :user) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("gemini-1.5-flash")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 2,
        completion_tokens: 11,
        total_tokens: 13
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(response).to be_a(LLM::Response::Completion).and have_attributes(
          choices: [
            have_attributes(
              role: "model",
              content: "Hello there! How can I help you today?\n"
            )
          ]
        )
      end

      it "includes the response" do
        expect(choice.extra[:response]).to eq(response)
      end
    end
  end

  context "when given a thread of messages",
          vcr: {cassette_name: "gemini/completions/successful_response_thread"} do
    subject(:response) do
      gemini.complete "What is your name? What age are you?", :user, messages: [
        {role: "user", content: "Answer all of my questions"},
        {role: "user", content: "Your name is Pablo, you are 25 years old and you are my amigo"}
      ]
    end

    it "has choices" do
      expect(response).to have_attributes(
        choices: [
          have_attributes(
            role: "model",
            content: "My name is Pablo, and I am 25 years old.  ¡Amigo!\n"
          )
        ]
      )
    end
  end

  context "when given an unauthorized response",
          vcr: {cassette_name: "gemini/completions/unauthorized_response"} do
    subject(:response) { gemini.complete("Hello!", :user) }
    let(:token) { "BADTOKEN" }

    it "raises an error" do
      expect { response }.to raise_error(LLM::Error::Unauthorized)
    end

    it "includes a response" do
      response
    rescue LLM::Error::Unauthorized => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end
end
