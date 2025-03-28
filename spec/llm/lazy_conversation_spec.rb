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
        is_expected.to have_attributes(
          role: "model",
          content: "I am doing well, thank you for asking!  How are you today?\n"
        )
      end

      context "#recent_message" do
        context "when filtered by the assistant role" do
          subject(:message) { conversation.recent_message }

          it "returns the most recent assistant message" do
            is_expected.to have_attributes(
              role: "model",
              content: "I am doing well, thank you for asking!  How are you today?\n"
            )
          end
        end

        context "when filtered by the user role" do
          subject(:message) { conversation.recent_message(role: "user") }

          it "returns the most recent user message" do
            is_expected.to have_attributes(
              role: "user",
              content: "How are you?"
            )
          end
        end
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
        is_expected.to have_attributes(
          role: "assistant",
          content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help! What’s your question?"
        )
      end

      context "#recent_message" do
        context "when filtered by the assistant role" do
          subject(:message) { conversation.recent_message }

          it "returns the most recent assistant message" do
            is_expected.to have_attributes(
              role: "assistant",
              content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help! What’s your question?"
            )
          end
        end

        context "when filtered by the user role" do
          subject(:message) { conversation.recent_message(role: "user") }

          it "returns the most recent user message" do
            is_expected.to have_attributes(
              role: "user",
              content: "How are you?"
            )
          end
        end
      end
    end
  end

  context "with ollama",
          vcr: {cassette_name: "ollama/lazy_conversation/successful_response"} do
    let(:provider) { LLM.ollama(nil, host: "eel.home.network") }
    let(:conversation) { described_class.new(provider) }

    context "when given a thread of messages" do
      subject(:message) { conversation.messages.to_a[-1] }

      before do
        conversation.chat "Hello"
        conversation.chat "I have a question"
        conversation.chat "How are you?"
      end

      it "maintains a conversation" do
        is_expected.to have_attributes(
          role: "assistant",
          content: "Hello! I'm just a computer program, so I don't have feelings or emotions " \
                   "like humans do. I'm functioning properly and ready to help with any questions " \
                   "or topics you'd like to discuss. How can I assist you today?"
        )
      end

      context "#recent_message" do
        context "when filtered by the assistant role" do
          subject(:message) { conversation.recent_message }

          it "returns the most recent assistant message" do
            is_expected.to have_attributes(
              role: "assistant",
              content: "Hello! I'm just a computer program, so I don't have feelings or emotions " \
                       "like humans do. I'm functioning properly and ready to help with any questions " \
                       "or topics you'd like to discuss. How can I assist you today?"
            )
          end
        end

        context "when filtered by the user role" do
          subject(:message) { conversation.recent_message(role: "user") }

          it "returns the most recent user message" do
            is_expected.to have_attributes(
              role: "user",
              content: "How are you?"
            )
          end
        end
      end
    end
  end
end
