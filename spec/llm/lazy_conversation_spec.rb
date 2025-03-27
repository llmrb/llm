# frozen_string_literal: true

require "setup"

RSpec.describe LLM::LazyConversation do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }

  context "with gemini",
          vcr: {cassette_name: "gemini/lazy_conversation/successful_response"} do
    let(:provider) { LLM.gemini(token) }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        expect(message).to have_attributes(
          role: "model",
          content: "I am doing well, thank you for asking!  How are you today?\n"
        )
      end
    end
  end

  context "with openai",
          vcr: {cassette_name: "openai/lazy_conversation/successful_response"} do
    let(:provider) { LLM.openai(token) }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        expect(message).to have_attributes(
          role: "assistant",
          content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help! What’s your question?"
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
