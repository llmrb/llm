# frozen_string_literal: true

require "setup"

RSpec.describe LLM::LazyConversation do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:prompt) { "Keep your answers short and concise, and provide three answers to the three questions" }

  context "with gemini",
          vcr: {cassette_name: "gemini/lazy_conversation/successful_response"} do
    let(:provider) { LLM.gemini(token) }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        conversation.chat prompt
        conversation.chat "What is 3+2 ?"
        conversation.chat "What is 5+5 ?"
        conversation.chat "What is 5+7 ?"
      end

      it "maintains a conversation" do
        is_expected.to have_attributes(
          role: "model",
          content: "5\n10\n12\n"
        )
      end
    end
  end

  context "with openai",
          vcr: {cassette_name: "openai/lazy_conversation/successful_response"} do
    let(:provider) { LLM.openai(token) }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.recent_message }

      before do
        conversation.chat prompt, :system
        conversation.chat "What is 3+2 ?"
        conversation.chat "What is 5+5 ?"
        conversation.chat "What is 5+7 ?"
      end

      it "maintains a conversation" do
        is_expected.to have_attributes(
          role: "assistant",
          content: "1. 5  \n2. 10  \n3. 12  "
        )
      end
    end
  end

  context "with ollama",
          vcr: {cassette_name: "ollama/lazy_conversation/successful_response"} do
    let(:provider) { LLM.ollama(nil, host: "eel.home.network") }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.recent_message }

      before do
        conversation.chat prompt, :system
        conversation.chat "What is 3+2 ?"
        conversation.chat "What is 5+5 ?"
        conversation.chat "What is 5+7 ?"
      end

      it "maintains a conversation" do
        is_expected.to have_attributes(
          role: "assistant",
          content: "Here are the calculations:\n\n1. 3 + 2 = 5\n2. 5 + 5 = 10\n3. 5 + 7 = 12"
        )
      end
    end
  end
end
