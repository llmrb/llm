# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Conversation: gemini" do
  let(:described_class) { LLM::Conversation }
  let(:provider) { LLM.gemini(token) }
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:conversation) { described_class.new(provider, **params).lazy }

  context "when asked to describe an image",
          vcr: {cassette_name: "gemini/conversations/multimodal_response"} do
    subject { conversation.last_message }

    let(:params) { {} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      conversation.chat(image, :user)
      conversation.chat("Describe the image with a short sentance", :user)
    end

    it "describes the image" do
      is_expected.to have_attributes(
        role: "model",
        content: "That's a simple illustration of a book " \
                 "resting on a blue, X-shaped book stand.\n"
      )
    end
  end
end
