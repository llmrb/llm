# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::Anthropic" do
  subject(:anthropic) { LLM.anthropic("") }

  before(:each, :success) do
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: '{
          "content": [
            {
              "text": "Hi! My name is Claude.",
              "type": "text"
            }
          ],
          "id": "msg_013Zva2CMHLNnXjNJJKqJ2EF",
          "model": "claude-3-5-sonnet-20240620",
          "role": "assistant",
          "stop_reason": "end_turn",
          "stop_sequence": null,
          "type": "message",
          "usage": {
            "input_tokens": 2095,
            "output_tokens": 503
          }
        }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 403,
        body: '{
          "type": "error",
          "error": {
            "type": "invalid_request_error",
            "message": "<string>"
          }
          }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  context "with successful completion", :success do
    let(:message) { ["Hello, world", :user] }
    let(:completion) { anthropic.complete(*message) }
    let(:choice) { completion.choices[0] }

    it "returns a completion" do
      expect(completion).to be_a(LLM::Response::Completion)
    end

    it "has model" do
      expect(completion.model).to eq("claude-3-5-sonnet-20240620")
    end

    it "has choices" do
      expect(completion.choices.first).to have_attributes(
        role: "assistant",
        content: "Hi! My name is Claude."
      )
    end

    it "has token usage" do
      expect(completion).to have_attributes(
        prompt_tokens: 2095,
        completion_tokens: 503,
        total_tokens: 2598
      )
    end

    it "stores the completion as context" do
      expect(choice.context[:completion]).to eq(completion)
    end
  end

  context "with an unauthorized error", :unauthorized do
    let(:completion) { anthropic.complete("Hello", :user) }

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
