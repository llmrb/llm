# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: gemini" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.gemini(key:) }
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
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
          vcr: {cassette_name: "gemini/conversations/multimodal_response", match_requests_on: [:method]} do
    subject { bot.messages.find(&:assistant?).content.downcase[0..2] }

    let(:params) { {} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      bot.chat([
        "Does this resemable a book?",
        "Answer with yes or no. Nothing else.",
        image
      ], role: :user)
    end

    it "describes the image" do
      is_expected.to eq("yes")
    end
  end

  context "when given an empty array",
          vcr: {cassette_name: "gemini/conversations/empty_function_call", match_requests_on: [:method]} do
    before { bot.chat("Hello! Nice to meet you", role: :user) }
    let(:params) { {} }

    it "does not raise an error" do
      bot.chat []
      expect { bot.messages.to_a }.not_to raise_error
    end
  end

  context "when given an instance of LLM::Function::Return",
          vcr: {cassette_name: "gemini/conversations/system_function_call_1", match_requests_on: [:method]} do
    let(:params) { {tools: [tool]} }
    let(:prompt) do
      "You are a bot that can run UNIX system commands. " \
      "When the command is successful I will respond with true. " \
      "Otherwise false. "
    end

    before do
      bot.chat(prompt, role: :user)
      bot.chat("Hey, tell me the date", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions[0].call
      expect(bot.functions).to be_empty
    end
  end

  context "when given an instance of LLM::Function::Return (via an array)",
          vcr: {cassette_name: "gemini/conversations/system_function_call_2", match_requests_on: [:method]} do
    let(:params) {  {tools: [tool]} }
    let(:prompt) do
      "You are a bot that can run UNIX system commands. " \
      "When the command is successful I will respond with true. " \
      "Otherwise false. "
    end

    before do
      bot.chat(prompt, role: :user)
      bot.chat("Hey, tell me the date", role: :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end
  end
end
