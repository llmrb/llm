# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: ollama" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.ollama(nil, host: "eel.home.network") }
  let(:bot) { described_class.new(provider, **params).lazy }

  context "when asked to describe an image",
          vcr: {cassette_name: "ollama/conversations/multimodal_response"} do
    subject { bot.messages.find(&:assistant?) }

    let(:params) { {model: "llava"} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      bot.chat(image, :user)
      bot.chat("Describe the image with a short sentance", :user)
    end

    it "describes the image" do
      is_expected.to have_attributes(
        role: "assistant",
        content: " The image is a graphic illustration of a book" \
                 " with its pages spread out, symbolizing openness" \
                 " or knowledge. "
      )
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
      bot.chat("Hey, tell me the date", :user)
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.functions.each(&:call)
    end
  end
end
