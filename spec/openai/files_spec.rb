# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Files" do
  let(:token) { ENV["LLM_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(token) }

  context "when given a successful create operation (haiku1.txt)",
          vcr: {cassette_name: "openai/files/successful_create_haiku1"} do
    subject(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku1.txt")) }

    it "is successful" do
      expect(file).to be_instance_of(LLM::Response::File)
    ensure
      provider.files.delete(file:)
    end

    it "returns a file object" do
      expect(file).to have_attributes(
        id: instance_of(String),
        filename: "haiku1.txt",
        purpose: "assistants"
      )
    ensure
      provider.files.delete(file:)
    end
  end

  context "when given a successful create operation (haiku2.txt)",
          vcr: {cassette_name: "openai/files/successful_create_haiku2"} do
    subject(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/haiku2.txt")) }

    it "is successful" do
      expect(file).to be_instance_of(LLM::Response::File)
    ensure
      provider.files.delete(file:)
    end

    it "returns a file object" do
      expect(file).to have_attributes(
        id: instance_of(String),
        filename: "haiku2.txt",
        purpose: "assistants"
      )
    ensure
      provider.files.delete(file:)
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

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::File)
    ensure
      provider.files.delete(file:)
    end

    it "returns a file object" do
      is_expected.to have_attributes(
        id: instance_of(String),
        filename: "haiku4.txt",
        purpose: "assistants"
      )
    ensure
      provider.files.delete(file:)
    end
  end

  context "when given a successful all operation",
          vcr: {cassette_name: "openai/files/successful_all"} do
    let!(:files) do
      [
        provider.files.create(file: LLM::File("spec/fixtures/documents/haiku1.txt")),
        provider.files.create(file: LLM::File("spec/fixtures/documents/haiku2.txt"))
      ]
    end
    subject(:filelist) { provider.files.all }

    it "is successful" do
      expect(filelist).to be_instance_of(LLM::Response::FileList)
    ensure
      files.each { |file| provider.files.delete(file:) }
    end

    it "returns an array of file objects" do
      expect(filelist.files[0..1]).to match_array(
        [
          have_attributes(
            id: instance_of(String),
            filename: "haiku1.txt",
            purpose: "assistants"
          ),
          have_attributes(
            id: instance_of(String),
            filename: "haiku2.txt",
            purpose: "assistants"
          )
        ]
      )
    ensure
      files.each { |file| provider.files.delete(file:) }
    end
  end

  context "when asked to describe the contents of a file",
          vcr: {cassette_name: "openai/files/describe_freebsd.sysctl.pdf"} do
    subject { bot.last_message.content.downcase[0..2] }
    let(:bot) { LLM::Chat.new(provider).lazy }
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/freebsd.sysctl.pdf")) }

    before do
      bot.respond(file)
      bot.respond("Is this PDF document about FreeBSD?")
      bot.respond("Answer with yes or no. Nothing else.")
    end

    it "describes the document" do
      is_expected.to eq("yes")
    ensure
      provider.files.delete(file:)
    end
  end

  context "when asked to describe the contents of a file",
          vcr: {cassette_name: "openai/files/describe_freebsd.sysctl_2.pdf"} do
    subject { bot.last_message.content.downcase[0..2] }
    let(:bot) { LLM::Chat.new(provider).lazy }
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/freebsd.sysctl.pdf")) }

    before do
      bot.respond([
        "Is this PDF document about FreeBSD?",
        "Answer with yes or no. Nothing else.",
        file
      ])
    end

    it "describes the document" do
      is_expected.to eq("yes")
    ensure
      provider.files.delete(file:)
    end
  end

  context "when asked to describe the contents of a file",
          vcr: {cassette_name: "openai/files/describe_freebsd.sysctl_3.pdf"} do
    subject { bot.last_message.content.downcase[0..2] }
    let(:bot) { LLM::Chat.new(provider).lazy }
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/freebsd.sysctl.pdf")) }

    before do
      bot.chat(file)
      bot.chat("Is this PDF document about FreeBSD?")
      bot.chat("Answer with yes or no. Nothing else.")
    end

    it "describes the document" do
      is_expected.to eq("yes")
    ensure
      provider.files.delete(file:)
    end
  end

  context "when asked to describe the contents of a file",
          vcr: {cassette_name: "openai/files/describe_freebsd.sysctl_4.pdf"} do
    subject { bot.last_message.content.downcase[0..2] }
    let(:bot) { LLM::Chat.new(provider).lazy }
    let(:file) { provider.files.create(file: LLM::File("spec/fixtures/documents/freebsd.sysctl.pdf")) }

    before do
      bot.chat([
        "Is this PDF document about FreeBSD?",
        "Answer with yes or no. Nothing else.",
        file
      ])
    end

    it "describes the document" do
      is_expected.to eq("yes")
    ensure
      provider.files.delete(file:)
    end
  end
end
