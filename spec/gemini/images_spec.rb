# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini::Images" do
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.gemini(key:) }

  context "when given a successful create operation",
        vcr: {cassette_name: "gemini/images/successful_create", match_requests_on: [:method]} do
    subject(:response) { provider.images.create(prompt: "A dog on a rocket to the moon") }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response)
    end

    it "returns an IO-like object" do
      expect(response.images[0]).to be_instance_of(StringIO)
    end
  end

  context "when given a successful edit operation",
        vcr: {cassette_name: "gemini/images/successful_edit", match_requests_on: [:method]} do
    subject(:response) do
      provider.images.edit(
        image: "spec/fixtures/images/bluebook.png",
        prompt: "Book is floating in the clouds"
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response)
    end

    it "returns an IO-like object" do
      expect(response.images[0]).to be_instance_of(StringIO)
    end
  end
end
