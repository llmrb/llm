# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.openai(key:) }
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, **params).lazy }

  let(:tool) do
    LLM.function(:system) do |fn|
      fn.description "Runs system commands, emits their output"
      fn.params do |schema|
        schema.object(command: schema.string.required)
      end
      fn.define do |params|
        Kernel.system(params.command)
      end
    end
  end

  context "when given an instance of LLM::Function",
          vcr: {cassette_name: "openai/conversations/system_function_call_1"} do
    let(:params) { {tools: [tool]} }

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions[0].call
      expect(bot.functions).to be_empty
    end
  end

  context "when given an instance of LLM::Function (via an array)",
          vcr: {cassette_name: "openai/conversations/system_function_call_2"} do
    let(:params) { {tools: [tool]} }

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end
  end
end
