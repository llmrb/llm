# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI: completions" do
  subject(:openai) { LLM.openai(token) }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }

  context "when given a successful response",
          vcr: {cassette_name: "openai/completions/successful_response"} do
    subject(:response) { openai.complete("Hello!", :user) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("gpt-4o-mini-2024-07-18")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 9,
        completion_tokens: 10,
        total_tokens: 19
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(choice).to have_attributes(
          role: "assistant",
          content: "Hello! How can I assist you today?"
        )
      end

      it "includes the response" do
        expect(choice.extra[:completion]).to eq(response)
      end
    end
  end

  context "when given an unauthorized response",
          vcr: {cassette_name: "openai/completions/unauthorized_response"} do
    subject(:response) { openai.complete(LLM::Message.new("Hello!", :user)) }
    let(:token) { "BADTOKEN" }

    it "raises an error" do
      expect { response }.to raise_error(LLM::Error::Unauthorized)
    end

    it "includes the response" do
      response
    rescue LLM::Error::Unauthorized => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end

  context "when given a 'bad request' response",
          vcr: {cassette_name: "openai/completions/bad_request"} do
    subject(:response) { openai.complete(URI("/foobar.exe"), :user) }

    it "raises an error" do
      expect { response }.to raise_error(LLM::Error::BadResponse)
    end

    it "includes the response" do
      response
    rescue LLM::Error => ex
      expect(ex.response).to be_instance_of(Net::HTTPBadRequest)
    end
  end
end
