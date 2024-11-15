# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::OpenAI" do
  subject(:openai) { LLM.openai("") }

  before(:each, :success) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: '{
          "id": "chatcmpl-AFIwpAMVniQWeOJZDYZ1IZpcf8zQa",
          "object": "chat.completion",
          "created": 1728211119,
          "model": "gpt-4o-mini-2024-07-18",
          "choices": [
            {
              "index": 0,
              "message": {
                "role": "assistant",
                "content": "Hello! How can I assist you today?",
                "refusal": null
              },
              "logprobs": null,
              "finish_reason": "stop"
            }
          ],
          "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 9,
            "total_tokens": 18,
            "prompt_tokens_details": {
              "cached_tokens": 0
            },
            "completion_tokens_details": {
              "reasoning_tokens": 0
            }
          },
          "system_fingerprint": "fp_f85bea6784"
        }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 401,
        body: '{
          "error": {
            "message": "Incorrect API key provided: sk-6WQZM***************************************t6ea. You can find your API key a t https://platform.openai.com/account/api-keys.",
            "type": "invalid_request_error",
            "param": null,
            "code": "invalid_api_key"
          }
          }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :bad_request) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 400,
        body: {
          error: {
            message: "Failed to download image from /path/to/nowhere.bin. Image URL is invalid.",
            type: "invalid_request_error",
            param: nil,
            code: "invalid_image_url"
          }
        }.to_json
      )
  end

  context "with successful completion", :success do
    let(:completion) { openai.complete("Hello!", :user) }

    it "returns a completion" do
      expect(completion).to be_a(LLM::Response::Completion)
    end

    it "has model" do
      expect(completion.model).to eq("gpt-4o-mini-2024-07-18")
    end

    it "has choices" do
      expect(completion.choices.first).to have_attributes(
        role: "assistant",
        content: "Hello! How can I assist you today?"
      )
    end

    it "has token usage" do
      expect(completion).to have_attributes(
        prompt_tokens: 9,
        completion_tokens: 9,
        total_tokens: 18
      )
    end
  end

  context "with an unauthorized error", :unauthorized do
    let(:completion) { openai.complete(LLM::Message.new("Hello!", :user)) }

    it "raises an error" do
      expect { completion }.to raise_error(LLM::Error::Unauthorized)
    end

    it "includes a response" do
      completion
    rescue LLM::Error::Unauthorized => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end

  context "with a bad request", :bad_request do
    subject(:completion) { openai.complete(URI("/path/to/nowhere.bin"), :user) }

    it "raises an error" do
      expect { completion }.to raise_error(LLM::Error::BadResponse)
    end

    it "includees a response" do
      completion
    rescue LLM::Error => ex
      expect(ex.response).to be_instance_of(Net::HTTPBadRequest)
    end
  end
end
