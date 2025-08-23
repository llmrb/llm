# frozen_string_literal: true

require_relative "setup"

RSpec.describe LLM::Buffer do
  let(:llm) { LLM.openai(key: "sk-xxxx") }
  let(:bot) { LLM::Bot.new(llm) }
  let(:buffer) { bot.messages }

  context "when given request-level parameters" do
    let(:params) { {model: "gpt-4.1", stream: true} }
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
end
