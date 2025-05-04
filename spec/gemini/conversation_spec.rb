# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: gemini" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.gemini(token) }
  let(:token) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, **params).lazy }

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
      ], :user)
    end

    it "describes the image" do
      is_expected.to eq("yes")
    end
  end

  context "when given a system function",
          vcr: {cassette_name: "gemini/conversations/system_function_call", match_requests_on: [:method]} do
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

  context "when given an empty array",
          vcr: {cassette_name: "gemini/conversations/empty_function_call", match_requests_on: [:method]} do
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
      bot.chat("Hello! Nice to meet you", :user)
    end

    it "does not error out" do
      bot.chat bot.functions.map(&:call)
      bot.messages.each { expect(_1).not_to be_tool_call }
    end
  end
end
