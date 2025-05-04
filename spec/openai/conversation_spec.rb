# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.openai(token) }
  let(:token) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, **params).lazy }

  context "when given a system function",
          vcr: {cassette_name: "openai/conversations/system_function_call"} do
    let(:params) do
      {tools: [tool]}
    end

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

    before do
      bot.chat("You are a bot that can run UNIX system commands", :user)
      bot.chat("Hey, tell me the date", :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.functions.each(&:call)
    end
  end
end
