# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Files" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(token) }

  context "when given a successful create operation (haiku1.txt)",
          vcr: {cassette_name: "openai/files/successful_create_haiku1"} do
    subject(:response) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku1.txt")) }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::File)
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
      expect(response).to be_instance_of(LLM::Response::File)
    end

    it "returns a file object" do
      expect(response).to have_attributes(
        id: instance_of(String),
        filename: "haiku2.txt",
        purpose: "user_data"
      )
    end
  end

  context "when given a successful delete operation (haiku3.txt)",
          vcr: {cassette_name: "openai/files/successful_delete_haiku3"} do
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku3.txt")) }
    subject { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_instance_of(OpenStruct)
    end

    it "returns deleted status" do
      is_expected.to have_attributes(
        deleted: true
      )
    end
  end

  context "when given a successful get operation (haiku4.txt)",
          vcr: {cassette_name: "openai/files/successful_get_haiku4"} do
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku4.txt")) }
    subject { provider.files.get(file:) }
    after { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::File)
    end

    it "returns a file object" do
      is_expected.to have_attributes(
        id: instance_of(String),
        filename: "haiku4.txt",
        purpose: "user_data"
      )
    end
  end

  context "when given a successful all operation",
          vcr: {cassette_name: "openai/files/successful_all"} do
    subject(:response) { provider.files.all }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::FileList)
    end

    it "returns an array of file objects" do
      expect(response).to match_array(
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
