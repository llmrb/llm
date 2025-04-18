# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Images" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(token) }

  context "when given a successful creation",
        vcr: {cassette_name: "openai/images/successful_creation"} do
    subject(:response) { provider.images.create(prompt: "A dog on a rocket to the moon") }

    it "is successful" do
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns data" do
      expect(response.data).to be_instance_of(Array)
    end

    it "returns a url" do
      expect(response.data[0].url).to be_instance_of(String)
    end
  end

  context "when given a successful variation",
        vcr: {cassette_name: "openai/images/successful_variation"} do
    subject(:response) do
      provider.images.create_variation(
        image: LLM::File("spec/fixtures/images/bluebook.png"),
        n: 5
      )
    end

    it "is successful" do
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns data" do
      expect(response.data.size).to eq(5)
    end

    it "returns multiple variations" do
      response.data.each { expect(_1.url).to be_instance_of(String) }
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
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns data" do
      expect(response.data).to be_instance_of(Array)
    end

    it "returns a url" do
      expect(response.data[0].url).to be_instance_of(String)
    end
  end
end
