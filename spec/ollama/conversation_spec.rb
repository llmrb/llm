# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Conversation" do
  let(:described_class) { LLM::Conversation }
  let(:provider) { LLM.ollama(nil, host: "eel.home.network") }
  let(:conversation) { described_class.new(provider, **params).lazy }

  context "when asked to describe an image",
          vcr: {cassette_name: "ollama/conversations/multimodal_response"} do
    subject { conversation.last_message }

    let(:params) { {model: "llava"} }
    let(:image) { LLM::File("spec/fixtures/images/bluebook.png") }

    before do
      conversation.chat(image, :user)
      conversation.chat("Describe the image with a short sentance", :user)
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
end
