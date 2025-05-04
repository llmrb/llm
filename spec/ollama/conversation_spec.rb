# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: ollama" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.ollama(nil, host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, **params).lazy }

  context "when asked to describe an image",
          vcr: {cassette_name: "ollama/conversations/multimodal_response"} do
    subject { bot.messages.find(&:assistant?).content.downcase.strip[0..2] }

    let(:params) { {model: "llava"} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      bot.chat("Provide yes or no answers. Nothing else.", :system)
      bot.chat(image, :user)
      bot.chat("Do you see an image ?", :user)
    end

    it "describes the image" do
      is_expected.to eq("yes")
    end
  end

  context "when given a system function",
        vcr: {cassette_name: "ollama/conversations/system_function_call"} do
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
      bot.chat("Hey, tell me the date via the given 'system' tool", :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
    end
  end
end
