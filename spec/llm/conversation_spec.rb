# frozen_string_literal: true

RSpec.describe LLM::Conversation do
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
