# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini::Files" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.gemini(token) }

  context "when given a successful create operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_create_bismillah"} do
    subject(:file) { provider.files.create(file: LLM::File("spec/fixtures/audio/bismillah.mp3")) }
    after { provider.files.delete(file:) }

    it "is successful" do
      expect(file).to be_instance_of(LLM::Response::File)
    end

    it "returns a file object" do
      expect(file).to have_attributes(
        name: instance_of(String),
        display_name: "bismillah.mp3"
      )
    end
  end

  context "when given a successful delete operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_delete_bismillah"} do
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/audio/bismillah.mp3")) }
    subject { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_instance_of(Net::HTTPOK)
    end
  end

  context "when given a successful get operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_get_bismillah"} do
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/audio/bismillah.mp3")) }
    subject { provider.files.get(file:) }
    after { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::File)
    end

    it "returns a file object" do
      is_expected.to have_attributes(
        name: instance_of(String),
        display_name: "bismillah.mp3"
      )
    end
  end

  context "when given a successful all operation",
          vcr: {cassette_name: "gemini/files/successful_all"} do
    let!(:files) do
      [
        provider.files.create(file: LLM::File("spec/fixtures/audio/bismillah.mp3")),
        provider.files.create(file: LLM::File("spec/fixtures/audio/alhamdullilah.mp3"))
      ]
    end

    subject(:response) { provider.files.all }
    after { files.each { |file| provider.files.delete(file:) } }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response::FileList)
    end

    it "returns an array of file objects" do
      expect(response).to match_array(
        [
          have_attributes(
            name: instance_of(String),
            display_name: "bismillah.mp3"
          ),
          have_attributes(
            name: instance_of(String),
            display_name: "alhamdullilah.mp3"
          )
        ]
      )
    end
  end
end
