# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini: completions" do
  subject(:gemini) { LLM.gemini(key:) }

  context "when given a successful response",
          vcr: {cassette_name: "gemini/completions/successful_response", match_requests_on: [:method]} do
    subject(:response) { gemini.complete("Hello!", role: :user) }
    let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response)
    end

    it "returns a model" do
      expect(response.model).to eq("gemini-2.5-flash")
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
        expect(response).to be_a(LLM::Response).and have_attributes(
          choices: [
            have_attributes(
              role: "model",
              content: instance_of(String)
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
          vcr: {cassette_name: "gemini/completions/successful_response_thread", match_requests_on: [:method]} do
    subject(:response) do
      gemini.complete "What is your name?",
                      role: :user,
                      messages: [
                        {role: "user", content: "Answer all of my questions"},
                        {role: "user", content: "Your name is John"}
                      ]
    end
    let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }

    it "has choices" do
      expect(response).to have_attributes(
        choices: [
          have_attributes(
            role: "model",
            content: /John/i
          )
        ]
      )
    end
  end

  context "when given an unauthorized response",
          vcr: {cassette_name: "gemini/completions/unauthorized_response", match_requests_on: [:method]} do
    subject(:response) { gemini.complete("Hello!", role: :user) }
    let(:key) { "TOKEN" }

    it "raises an error" do
      expect { response }.to raise_error(LLM::UnauthorizedError)
    end

    it "includes a response" do
      response
    rescue LLM::UnauthorizedError => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end
end
