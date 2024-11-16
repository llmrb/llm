# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::Gemini" do
  subject(:gemini) { LLM.gemini("") }

  before(:each, :success) do
    stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: '{
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "Hello! How can I help you today? \n"
                  }
                ],
                "role": "model"
              },
              "finishReason": "STOP",
              "index": 0,
              "safetyRatings": [
                {
                  "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                  "probability": "NEGLIGIBLE"
                },
                {
                  "category": "HARM_CATEGORY_HATE_SPEECH",
                  "probability": "NEGLIGIBLE"
                },
                {
                  "category": "HARM_CATEGORY_HARASSMENT",
                  "probability": "NEGLIGIBLE"
                },
                {
                  "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                  "probability": "NEGLIGIBLE"
                }
              ]
            }
          ],
          "usageMetadata": {
            "promptTokenCount": 2,
            "candidatesTokenCount": 10,
            "totalTokenCount": 12
          },
          "modelVersion": "gemini-1.5-flash-001"
        }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 400,
        body: '{
          "error": {
            "code": 400,
            "message": "API key not valid. Please pass a valid API key.",
            "status": "INVALID_ARGUMENT",
            "details": [
              {
                "@type": "type.googleapis.com/google.rpc.ErrorInfo",
                "reason": "API_KEY_INVALID",
                "domain": "googleapis.com",
                "metadata": {
                  "service": "generativelanguage.googleapis.com"
                }
              }
            ]
          }
        }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "with successful completion", :success do
    let(:completion) { gemini.complete(LLM::Message.new("user", "Hello!")) }
    let(:choice) { completion.choices[0] }

    it "returns a completion" do
      expect(completion).to be_a(LLM::Response::Completion)
    end

    it "has model" do
      expect(completion.model).to eq("gemini-1.5-flash-001")
    end

    it "has choices" do
      expect(completion).to be_a(LLM::Response::Completion).and have_attributes(
        choices: [
          have_attributes(
            role: "model",
            content: "Hello! How can I help you today? \n"
          )
        ]
      )
    end

    it "has token usage" do
      expect(completion).to have_attributes(
        prompt_tokens: 2,
        completion_tokens: 10,
        total_tokens: 12
      )
    end

    it "stores the completion as context" do
      expect(choice.extra[:completion]).to eq(completion)
    end
  end

  context "with an unauthorized error", :unauthorized do
    let(:completion) { gemini.complete(LLM::Message.new("user", "Hello!")) }

    it "raises an error" do
      expect { completion }.to raise_error(LLM::Error::Unauthorized)
    end

    it "includes a response" do
      completion
    rescue LLM::Error::Unauthorized => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end
end
