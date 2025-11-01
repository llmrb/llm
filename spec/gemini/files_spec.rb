# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Gemini::Files" do
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.gemini(key:) }

  context "when given a successful create operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_create_bismillah", match_requests_on: [:method]} do
    subject(:file) { provider.files.create(file: "spec/fixtures/audio/bismillah.mp3") }
    after { provider.files.delete(file:) }

    it "is successful" do
      expect(file).to be_instance_of(LLM::Response)
    end

    it "returns a file object" do
      expect(file).to have_attributes(
        name: instance_of(String),
        display_name: "bismillah.mp3"
      )
    end
  end

  context "when given a successful delete operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_delete_bismillah", match_requests_on: [:method]} do
    let(:file) { provider.files.create(file: "spec/fixtures/audio/bismillah.mp3") }
    subject { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_ok
    end
  end

  context "when given a successful get operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_get_bismillah", match_requests_on: [:method]} do
    let(:file) { provider.files.create(file: "spec/fixtures/audio/bismillah.mp3") }
    subject { provider.files.get(file:) }
    after { provider.files.delete(file:) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "returns a file object" do
      is_expected.to have_attributes(
        name: instance_of(String),
        display_name: "bismillah.mp3"
      )
    end
  end

  context "when given a successful translation operation (bismillah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_translation_bismillah", match_requests_on: [:method]} do
    subject { bot.messages.find(&:assistant?).content.downcase.strip[0..2] }
    let(:file) { provider.files.create(file: "spec/fixtures/audio/bismillah.mp3") }
    let(:bot) { LLM::Bot.new(provider) }
    after { provider.files.delete(file:) }

    before do
      req = bot.build do |prompt|
        prompt.chat "Hello"
        prompt.chat "I want to ask you a question"
        prompt.chat "Can the following audio file be translated as:"
        prompt.chat "In the name of Allah, The Most Compassionate, The Most Merciful"
        prompt.chat "Answer with yes or no. Nothing else. Thank you."
        prompt.chat file
      end
      bot.chat(req)
    end

    it "translates the audio clip" do
      is_expected.to eq("yes")
    end
  end

  context "when given a successful translation operation (alhamdullilah.mp3)",
          vcr: {cassette_name: "gemini/files/successful_translation_alhamdullilah", match_requests_on: [:method]} do
    subject { bot.messages.find(&:assistant?).content }
    let(:file) { provider.files.create(file: "spec/fixtures/audio/alhamdullilah.mp3") }
    let(:bot) { LLM::Bot.new(provider) }
    after { provider.files.delete(file:) }

    before do
      bot.chat [
        "Translate the contents of the audio file into English",
        "Provide no other content except the translation",
        file
      ]
    end

    it "translates the audio clip" do
      is_expected.to match(/All praise is due to Allah, Lord of the worlds/i)
    end
  end

  context "when given a successful all operation",
          vcr: {cassette_name: "gemini/files/successful_all", match_requests_on: [:method]} do
    let!(:files) do
      [
        provider.files.create(file: "spec/fixtures/audio/bismillah.mp3"),
        provider.files.create(file: "spec/fixtures/audio/alhamdullilah.mp3")
      ]
    end

    subject(:response) { provider.files.all }
    after { files.each { |file| provider.files.delete(file:) } }

    it "is successful" do
      expect(response).to be_instance_of(LLM::Response)
    end

    it "returns an array of file objects" do
      expect(response.files).to match_array(
        [
          have_attributes(
            name: instance_of(String),
            displayName: "bismillah.mp3"
          ),
          have_attributes(
            name: instance_of(String),
            displayName: "alhamdullilah.mp3"
          )
        ]
      )
    end
  end
end
