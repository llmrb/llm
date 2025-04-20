# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini::Images" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.gemini(token) }

  context "when given a successful creation",
        vcr: {cassette_name: "gemini/images/successful_creation"} do
    subject(:response) { provider.images.create(prompt: "A dog on a rocket to the moon") }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns an encoded string" do
      expect(response.images[0].encoded).to be_instance_of(String)
    end

    it "returns a binary string" do
      expect(response.images[0].binary).to be_instance_of(String)
    end
  end

  context "when given a successful edit",
        vcr: {cassette_name: "gemini/images/successful_edit"} do
    subject(:response) do
      provider.images.edit(
        image: LLM::File("spec/fixtures/images/bluebook.png"),
        prompt: "Book is floating in the clouds"
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns data" do
      expect(response.images[0].encoded).to be_instance_of(String)
    end

    it "returns a url" do
      expect(response.images[0].binary).to be_instance_of(String)
    end
  end
end
