# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::Ollama" do
  subject(:ollama) { LLM.ollama("") }

  before(:each, :success) do
    stub_request(:post, "localhost:11434/api/chat")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: '{
          "model": "llama3.2",
          "created_at": "2023-12-12T14:13:43.416799Z",
          "message": {
            "role": "assistant",
            "content": "Hello! How are you today?"
          },
          "done": true,
          "total_duration": 5191566416,
          "load_duration": 2154458,
          "prompt_eval_count": 26,
          "prompt_eval_duration": 383809000,
          "eval_count": 298,
          "eval_duration": 4799921000
        }',
        headers: {"Content-Type" => "application/json"}
      )
  end

  # before(:each, :unauthorized) do
  #   stub_request(:post, "https://api.openai.com/v1/chat/completions")
  #     .with(headers: {"Content-Type" => "application/json"})
  #     .to_return(
  #       status: 401,
  #       body: '{
  #         "error": {
  #           "message": "Incorrect API key provided: sk-6WQZM***************************************t6ea. You can find your API key a t https://platform.openai.com/account/api-keys.",
  #           "type": "invalid_request_error",
  #           "param": null,
  #           "code": "invalid_api_key"
  #         }
  #         }',
  #       headers: {"Content-Type" => "application/json"}
  #     )
  # end

  # before(:each, :bad_request) do
  #   stub_request(:post, "https://api.openai.com/v1/chat/completions")
  #     .with(headers: {"Content-Type" => "application/json"})
  #     .to_return(
  #       status: 400,
  #       body: {
  #         error: {
  #           message: "Failed to download image from /path/to/nowhere.bin. Image URL is invalid.",
  #           type: "invalid_request_error",
  #           param: nil,
  #           code: "invalid_image_url"
  #         }
  #       }.to_json
  #     )
  # end

  context "with successful completion", :success do
    let(:completion) { ollama.complete("Hello!", :user) }
    let(:choice) { completion.choices[0] }

    it "returns a completion" do
      expect(completion).to be_a(LLM::Response::Completion)
    end

    it "has model" do
      expect(completion.model).to eq("llama3.2")
    end

    it "has choices" do
      expect(completion.choices.first).to have_attributes(
        role: "assistant",
        content: "Hello! How are you today?"
      )
    end

    it "has token usage" do
      expect(completion).to have_attributes(
        prompt_tokens: 26,
        completion_tokens: 298,
        total_tokens: 324
      )
    end

    it "stores the completion as context" do
      expect(choice.context[:completion]).to eq(completion)
    end
  end

  # context "with an unauthorized error", :unauthorized do
  #   let(:completion) { openai.complete(LLM::Message.new("user", "Hello!")) }

  #   it "raises an error" do
  #     expect { completion }.to raise_error(LLM::Error::Unauthorized)
  #   end

  #   it "includes a response" do
  #     completion
  #   rescue LLM::Error::Unauthorized => ex
  #     expect(ex.response).to be_kind_of(Net::HTTPResponse)
  #   end
  # end

  # context "with a bad request", :bad_request do
  #   subject(:completion) { openai.complete(LLM::Message.new("user", URI("/path/to/nowhere.bin"))) }

  #   it "raises an error" do
  #     expect { completion }.to raise_error(LLM::Error::BadResponse)
  #   end

  #   it "includees a response" do
  #     completion
  #   rescue LLM::Error => ex
  #     expect(ex.response).to be_instance_of(Net::HTTPBadRequest)
  #   end
  # end
end
