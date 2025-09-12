# frozen_string_literal: true

require_relative "setup"

RSpec.describe LLM::Buffer do
  let(:llm) { LLM.openai(key: "sk-xxxx") }
  let(:bot) { LLM::Bot.new(llm) }
  let(:buffer) { bot.messages }

  context "when given request-level parameters" do
    let(:params) { {model: llm.default_model, stream: true} }
    let(:res) { LLM::Object.from_hash(choices: []) }

    it "persists parameters between method calls" do
      bot.chat "abc", role: :system, stream: true
      bot.chat "def", role: :user
      expect(llm).to receive(:complete).with(
        "def", params.merge(role: "user", messages: instance_of(Array))
      ).and_return(res)
      buffer.to_a
    end

    it "gives precendence to the most recent parameter" do
      bot.chat "abc", role: :system, stream: true
      bot.chat "def", role: :user, stream: false
      expect(llm).to receive(:complete).with(
        "def", params.merge(stream: false, role: "user", messages: instance_of(Array))
      ).and_return(res)
      buffer.to_a
    end
  end

  describe "#[]" do
    context Range do
      let(:messages) do
        [
          LLM::Message.new(:system, "system"),
          LLM::Message.new(:user, "hi"),
          LLM::Message.new(:assistant, "hello"),
          LLM::Message.new(:user, "how are you?"),
          LLM::Message.new(:assistant, "I'm well")
        ]
      end

      before do
        buffer.instance_variable_set(:@completed, messages.dup)
      end

      context "when the range exists within the buffer" do
        it "returns a slice" do
          expect(buffer[1..3]).to eq(messages[1..3])
        end
      end

      context "when the range is out of bounds" do
        before do
          buffer.instance_variable_set(:@completed, [])
          allow(buffer).to receive(:to_a).and_return(messages)
        end

        it "populates the buffer" do
          expect(buffer[1..3]).to eq(messages[1..3])
        end
      end

      context "when given an invalid range" do
        it "raises TypeError" do
          expect { buffer[Object.new] }.to raise_error(TypeError)
        end
      end
    end
  end
end
