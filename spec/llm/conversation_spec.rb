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
                                .with(input.content, instance_of(Symbol), messages:, model: provider.default_model, schema: nil)
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

RSpec.describe "LLM::Chat: lazy" do
  let(:described_class) { LLM::Chat }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:prompt) do
    "Keep your answers short and concise, and provide three answers to the three questions" \
    "There should be one answer per line" \
    "An answer should be a number, for example: 5" \
    "Nothing else"
  end

  context "when given completions" do
    context "with gemini",
            vcr: {cassette_name: "gemini/lazy_conversation/successful_response"} do
      let(:provider) { LLM.gemini(token) }
      let(:bot) { described_class.new(provider).lazy }

      context "when given a thread of messages" do
        subject(:message) { bot.messages.to_a[-1] }

        before do
          bot.chat prompt
          bot.chat "What is 3+2 ?"
          bot.chat "What is 5+5 ?"
          bot.chat "What is 5+7 ?"
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
      let(:bot) { described_class.new(provider).lazy }

      context "when given a thread of messages",
              vcr: {cassette_name: "openai/lazy_conversation/completions/successful_response"} do
        subject(:message) { bot.messages.find(&:assistant?) }

        before do
          bot.chat prompt, :system
          bot.chat "What is 3+2 ?"
          bot.chat "What is 5+5 ?"
          bot.chat "What is 5+7 ?"
        end

        it "maintains a conversation" do
          is_expected.to have_attributes(
            role: "assistant",
            content: %r|5\s*\n10\s*\n12\s*|
          )
        end
      end

      context "when given a specific model",
              vcr: {cassette_name: "openai/lazy_conversation/completions/successful_response_o3_mini"} do
        let(:model) { provider.models.all.find { _1.id == "o3-mini" } }
        let(:bot) { described_class.new(provider, model:).lazy }

        it "maintains the model throughout a conversation" do
          bot.chat(prompt, :system)
          expect(bot.messages.find(&:assistant?).extra[:response].model).to eq("o3-mini-2025-01-31")
          bot.chat("What is 5+5?")
          expect(bot.messages.find(&:assistant?).extra[:response].model).to eq("o3-mini-2025-01-31")
        end
      end
    end

    context "with ollama",
            vcr: {cassette_name: "ollama/lazy_conversation/successful_response"} do
      let(:provider) { LLM.ollama(nil, host:) }
      let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
      let(:bot) { described_class.new(provider).lazy }

      context "when given a thread of messages" do
        subject(:message) { bot.messages.find(&:assistant?) }

        before do
          bot.chat prompt, :system
          bot.chat "What is 3+2 ?"
          bot.chat "What is 5+5 ?"
          bot.chat "What is 5+7 ?"
        end

        it "maintains a conversation" do
          is_expected.to have_attributes(
            role: "assistant",
            content: "5\n10\n12"
          )
        end
      end
    end
  end

  context "when given responses" do
    context "with openai"  do
      let(:provider) { LLM.openai(token) }
      let(:bot) { described_class.new(provider).lazy }

      context "when given a thread of messages",
              vcr: {cassette_name: "openai/lazy_conversation/responses/successful_response"} do
        subject(:message) { bot.messages.find(&:assistant?) }

        before do
          bot.respond prompt, :developer
          bot.respond "What is 3+2 ?"
          bot.respond "What is 5+5 ?"
          bot.respond "What is 5+7 ?"
        end

        it "maintains a conversation" do
          is_expected.to have_attributes(
            role: "assistant",
            content: %r|5\s*\n10\s*\n12\s*|
          )
        end
      end

      context "when given a specific model",
              vcr: {cassette_name: "openai/lazy_conversation/responses/successful_response_o3_mini"} do
        let(:model) { provider.models.all.find { _1.id == "o3-mini" } }
        let(:bot) { described_class.new(provider, model:).lazy }

        it "maintains the model throughout a conversation" do
          bot.respond(prompt, :developer)
          expect(bot.messages.find(&:assistant?).extra[:response].model).to eq("o3-mini-2025-01-31")
          bot.respond("What is 5+5?")
          expect(bot.messages.find(&:assistant?).extra[:response].model).to eq("o3-mini-2025-01-31")
        end
      end
    end
  end

  context "when given a schema as JSON" do
    context "with openai" do
      let(:provider) { LLM.openai(token) }
      let(:bot) { described_class.new(provider, schema:).lazy }

      context "when given a schema",
              vcr: {cassette_name: "openai/lazy_conversation/completions/successful_response_schema_netbsd"} do
        subject(:message) { bot.messages.find(&:assistant?).content! }
        let(:schema) { provider.schema.object({os: provider.schema.string.enum("OpenBSD", "FreeBSD", "NetBSD")}) }

        before do
          bot.chat "You secretly love NetBSD", :system
          bot.chat "What operating system is the best?", :user
        end

        it "formats the response" do
          is_expected.to eq("os" => "NetBSD")
        end
      end
    end

    context "with gemini" do
      let(:provider) { LLM.gemini(token) }
      let(:bot) { described_class.new(provider, schema:).lazy }

      context "when given a schema",
              vcr: {cassette_name: "gemini/lazy_conversation/completions/successful_response_schema_netbsd"} do
        subject(:message) { bot.messages.find(&:assistant?).content! }
        let(:schema) { provider.schema.object({os: provider.schema.string.enum("OpenBSD", "FreeBSD", "NetBSD")}) }

        before do
          bot.chat "You secretly love NetBSD", :user
          bot.chat "What operating system is the best?", :user
        end

        it "formats the response" do
          is_expected.to eq("os" => "NetBSD")
        end
      end
    end

    context "with ollama" do
      let(:provider) { LLM.ollama(nil, host:) }
      let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
      let(:bot) { described_class.new(provider, schema:).lazy }

      context "when given a schema",
              vcr: {cassette_name: "ollama/lazy_conversation/completions/successful_response_schema_netbsd"} do
        subject(:message) { bot.messages.find(&:assistant?).content! }

        let(:schema) do
          provider.schema.object({
            os: provider.schema.string.enum("OpenBSD", "FreeBSD", "NetBSD").required
          })
        end

        before do
          bot.chat "You secretly love NetBSD", :system
          bot.chat "What operating system is the best?", :user
        end

        it "formats the response" do
          is_expected.to eq("os" => "NetBSD")
        end
      end
    end
  end
end
