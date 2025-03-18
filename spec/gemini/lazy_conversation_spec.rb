# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe LLM::LazyConversation do
  let(:provider) { LLM.gemini("") }
  let(:conversation) { described_class.new(provider) }

  context "when given a thread of messages", :success do
    subject(:message) { conversation.messages.to_a[-1] }

    before(:each, :success) do
      stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=")
        .with(
          body: request_fixture("gemini/completions/ok_request.json"),
          headers: {"Content-Type" => "application/json"}
        )
        .to_return(
          status: 200,
          body: response_fixture("gemini/completions/ok_completion.json"),
          headers: {"Content-Type" => "application/json"}
        )
    end

    before do
      conversation.chat "Hello"
      conversation.chat "How are you?"
      conversation.chat "Goodbye"
    end

    it "maintains a conversation" do
      expect(message).to have_attributes(
        role: "model",
        content: "Hello! How can I help you today? \n"
      )
    end
  end
end
