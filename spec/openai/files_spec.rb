# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Images" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(token) }

  context "when given a successful create operation (haiku1.txt)",
          vcr: {cassette_name: "openai/files/successful_create_haiku1"} do
    subject(:response) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku1.txt")) }

    it "is successful" do
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns a file object" do
      expect(response).to have_attributes(
        id: instance_of(String),
        filename: "haiku1.txt",
        purpose: "user_data"
      )
    end
  end

  context "when given a successful create operation (haiku2.txt)",
          vcr: {cassette_name: "openai/files/successful_create_haiku2"} do
    subject(:response) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku2.txt")) }

    it "is successful" do
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns a file object" do
      expect(response).to have_attributes(
        id: instance_of(String),
        filename: "haiku2.txt",
        purpose: "user_data"
      )
    end
  end

  context "when given a successful all operation",
          vcr: {cassette_name: "openai/files/successful_all"} do
    subject(:response) { provider.files.all }

    it "is successful" do
      expect(response).to be_instance_of(OpenStruct)
    end

    it "returns an array of file objects" do
      expect(response.data).to match_array(
        [
          have_attributes(
            id: instance_of(String),
            filename: "haiku1.txt",
            purpose: "user_data"
          ),
          have_attributes(
            id: instance_of(String),
            filename: "haiku2.txt",
            purpose: "user_data"
          )
        ]
      )
    end
  end
end
