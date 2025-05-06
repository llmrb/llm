# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Images" do
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(key:) }

  context "when given a successful create operation (urls)",
          vcr: {cassette_name: "openai/images/successful_create_urls"} do
    subject(:response) { provider.images.create(prompt: "A dog on a rocket to the moon") }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns an array of urls" do
      expect(response.urls).to be_instance_of(Array)
    end

    it "returns a url" do
      expect(response.urls[0]).to be_instance_of(String)
    end
  end

  context "when given a successful create operation (base64)",
          vcr: {cassette_name: "openai/images/successful_create_base64"} do
    subject(:response) do
      provider.images.create(
        prompt: "A dog on a rocket to the moon",
        response_format: "b64_json"
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns an array of images" do
      expect(response.images).to be_instance_of(Array)
    end

    it "returns an IO-like object" do
      expect(response.images[0]).to be_instance_of(StringIO)
    end
  end

  context "when given a successful variation operation",
        vcr: {cassette_name: "openai/images/successful_variation"} do
    subject(:response) do
      provider.images.create_variation(
        image: LLM::File("spec/fixtures/images/bluebook.png"),
        n: 5
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns data" do
      expect(response.urls.size).to eq(5)
    end

    it "returns multiple variations" do
      response.urls.each { expect(_1).to be_instance_of(String) }
    end
  end

  context "when given a successful edit",
        vcr: {cassette_name: "openai/images/successful_edit"} do
    subject(:response) do
      provider.images.edit(
        image: LLM::File("spec/fixtures/images/bluebook.png"),
        prompt: "Add white background"
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::Image)
    end

    it "returns data" do
      expect(response.urls).to be_instance_of(Array)
    end

    it "returns a url" do
      expect(response.urls[0]).to be_instance_of(String)
    end
  end
end
