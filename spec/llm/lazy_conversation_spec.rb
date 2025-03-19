# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe LLM::LazyConversation do
  context "with gemini" do
    let(:provider) { LLM.gemini("") }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
          .with(
            headers: {"Content-Type" => "application/json"},
            body: request_fixture("gemini/completions/ok_completion.json")
          )
          .to_return(
            status: 200,
            body: response_fixture("gemini/completions/ok_completion.json"),
            headers: {"Content-Type" => "application/json"}
          )
      end

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        expect(message).to have_attributes(
          role: "model",
          content: "Hello! How can I help you today? \n"
        )
      end
    end
  end

  context "with openai" do
    let(:provider) { LLM.openai("") }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .with(
            headers: {"Content-Type" => "application/json"},
            body: request_fixture("openai/completions/ok_completion.json")
          )
          .to_return(
            status: 200,
            body: response_fixture("openai/completions/ok_completion.json"),
            headers: {"Content-Type" => "application/json"}
          )
      end

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        expect(message).to have_attributes(
          role: "assistant",
          content: "Hello! How can I assist you today?"
        )
      end
    end
  end

  context "with ollama" do
    let(:provider) { LLM.ollama("") }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        stub_request(:post, "http://localhost:11434/api/chat")
          .with(
            headers: {"Content-Type" => "application/json"},
            body: request_fixture("ollama/completions/ok_completion.json")
          )
          .to_return(
            status: 200,
            body: response_fixture("ollama/completions/ok_completion.json"),
            headers: {"Content-Type" => "application/json"}
          )
      end

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        expect(message).to have_attributes(
          role: "assistant",
          content: "Hello! How are you today?"
        )
      end
    end
  end
end
