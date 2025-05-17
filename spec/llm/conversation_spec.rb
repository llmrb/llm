# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: non-lazy" do
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
                                .with(input.content, {role: instance_of(Symbol), messages:, model: provider.default_model})
                                .and_return(LLM::Object.new(choices: [output]))
          bot = index.zero? ? provider.chat!(input.content, role: :system) : bot.chat(input.content)
          messages.concat([input, output])
        end
      end
    end
  end

  context "with openai" do
    subject(:provider) { LLM.openai(key: nil) }
    include_examples "a multi-turn conversation"
  end

  context "with gemini" do
    subject(:provider) { LLM.gemini(key: nil) }
    include_examples "a multi-turn conversation"
  end

  context "with anthropic" do
    subject(:provider) { LLM.anthropic(key: nil) }
    include_examples "a multi-turn conversation"
  end

  context "with ollama" do
    subject(:provider) { LLM.ollama(key: nil) }
    include_examples "a multi-turn conversation"
  end
end
