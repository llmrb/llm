# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: gemini" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.gemini(token) }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, **params).lazy }

  context "when asked to describe an image",
          vcr: {cassette_name: "gemini/conversations/multimodal_response"} do
    subject { bot.last_message }

    let(:params) { {} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      bot.chat(image, :user)
      bot.chat("Describe the image with a short sentance", :user)
    end

    it "describes the image" do
      is_expected.to have_attributes(
        role: "model",
        content: "That's a simple illustration of a book " \
                 "resting on a blue, X-shaped book stand.\n"
      )
    end
  end

  context "when given a system function",
          vcr: {cassette_name: "gemini/conversations/system_function_call"} do
    subject { bot.last_message }

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
