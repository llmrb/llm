# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: ollama" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params).lazy }

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

  context "when asked to describe an image",
          vcr: {cassette_name: "ollama/conversations/multimodal_response"} do
    subject { bot.messages.find(&:assistant?).content.downcase.strip[0..2] }

    let(:params) { {model: "llava"} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      bot.chat("Provide yes or no answers. Nothing else.", role: :system)
      bot.chat(image, role: :user)
      bot.chat("Do you see an image ?", role: :user)
    end

    it "describes the image" do
      is_expected.to eq("yes")
    end
  end

  context "when given an instance of LLM::Function::Return (via an array)",
        vcr: {cassette_name: "ollama/conversations/system_function_call_1"} do
    let(:params) { {tools: [tool]} }

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date via the given 'system' tool", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end
  end

  context "when given an instance of LLM::Function::Return",
          vcr: {cassette_name: "ollama/conversations/system_function_call_1"} do
    let(:params) { {tools: [tool]} }

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date via the given 'system' tool", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions[0].call
      expect(bot.functions).to be_empty
    end
  end
end
