# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Conversation: non-lazy" do
  shared_examples "a multi-turn conversation" do
    context "when given a thread of messages" do
      let(:inputs) do
        [
          LLM::Message.new(:system, "Provide concise, short answers about The Netherlands"),
          LLM::Message.new(:user, "What is the capital of The Netherlands?"),
          LLM::Message.new(:user, "How many people live in the capital?")
        ]
      end

      let(:outputs) do
        [
          LLM::Message.new(:assistant, "Ok, got it"),
          LLM::Message.new(:assistant, "The capital of The Netherlands is Amsterdam"),
          LLM::Message.new(:assistant, "The population of Amsterdam is about 900,000")
        ]
      end

      let(:messages) { [] }

      it "maintains a conversation" do
        bot = nil
        inputs.zip(outputs).each_with_index do |(input, output), index|
          expect(provider).to receive(:complete)
                                .with(input.content, instance_of(Symbol), messages:)
                                .and_return(OpenStruct.new(choices: [output]))
          bot = index.zero? ? provider.chat!(input.content, :system) : bot.chat(input.content)
          messages.concat([input, output])
        end
      end
    end
  end

  context "with openai" do
    subject(:provider) { LLM.openai("") }
    include_examples "a multi-turn conversation"
  end

  context "with gemini" do
    subject(:provider) { LLM.gemini("") }
    include_examples "a multi-turn conversation"
  end

  context "with anthropic" do
    subject(:provider) { LLM.anthropic("") }
    include_examples "a multi-turn conversation"
  end

  context "with ollama" do
    subject(:provider) { LLM.ollama("") }
    include_examples "a multi-turn conversation"
  end
end

RSpec.describe "LLM::Conversation: lazy" do
  let(:described_class) { LLM::Conversation }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:prompt) { "Keep your answers short and concise, and provide three answers to the three questions" }

  context "with gemini",
          vcr: {cassette_name: "gemini/lazy_conversation/successful_response"} do
    let(:provider) { LLM.gemini(token) }
    let(:conversation) { described_class.new(provider).lazy }

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

  context "with openai"  do
    let(:provider) { LLM.openai(token) }
    let(:conversation) { described_class.new(provider).lazy }

    context "when given a thread of messages",
            vcr: {cassette_name: "openai/lazy_conversation/successful_response"} do
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

    context "when given a specific model",
            vcr: {cassette_name: "openai/lazy_conversation/successful_response_o3_mini"} do
      let(:conversation) { described_class.new(provider, model: provider.models["o3-mini"]).lazy }

      it "maintains the model throughout a conversation" do
        conversation.chat(prompt, :system)
        expect(conversation.recent_message.extra[:completion].model).to eq("o3-mini-2025-01-31")
        conversation.chat("What is 5+5?")
        expect(conversation.recent_message.extra[:completion].model).to eq("o3-mini-2025-01-31")
      end
    end
  end

  context "with ollama",
          vcr: {cassette_name: "ollama/lazy_conversation/successful_response"} do
    let(:provider) { LLM.ollama(nil, host: "eel.home.network") }
    let(:conversation) { described_class.new(provider).lazy }

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
