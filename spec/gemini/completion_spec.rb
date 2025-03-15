# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::Gemini" do
  subject(:gemini) { LLM.gemini("") }

  before(:each, :success) do
    stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: fixture("gemini/completions/ok_completion.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 400,
        body: fixture("gemini/completions/unauthorized_completion.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "when given a successful response", :success do
    subject(:response) { gemini.complete(LLM::Message.new("user", "Hello!")) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("gemini-1.5-flash-001")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 2,
        completion_tokens: 10,
        total_tokens: 12
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(response).to be_a(LLM::Response::Completion).and have_attributes(
          choices: [
            have_attributes(
              role: "model",
              content: "Hello! How can I help you today? \n"
            )
          ]
        )
      end

      it "includes the response" do
        expect(choice.extra[:completion]).to eq(response)
      end
    end
  end

  context "when given an unauthorized response", :unauthorized do
    subject(:response) { gemini.complete(LLM::Message.new("user", "Hello!")) }

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
