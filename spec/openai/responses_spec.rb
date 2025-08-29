# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Responses" do
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(key:) }

  context "when given a successful create operation",
          vcr: {cassette_name: "openai/responses/successful_create"} do
    subject { provider.responses.create("Hello", role: :developer) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        choices: [instance_of(LLM::Message)]
      )
    end
  end

  context "when given a successful get operation",
          vcr: {cassette_name: "openai/responses/successful_get"} do
    let(:response) { provider.responses.create("Hello", role: :developer) }
    subject { provider.responses.get(response) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        choices: [instance_of(LLM::Message)]
      )
    end
  end

  context "when given a successful delete operation",
          vcr: {cassette_name: "openai/responses/successful_delete"} do
    let(:response) { provider.responses.create("Hello", role: :developer) }
    subject { provider.responses.delete(response) }

    it "is successful" do
      is_expected.to have_attributes(
        deleted: true
      )
    end
  end

  context "when given a json schema",
          vcr: {cassette_name: "openai/responses/json_schema"} do
    subject do
      schema = provider.schema.object(answer: provider.schema.string.required)
      provider.responses.create("What is the capital of France?", role: :user, schema:)
    end

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        choices: [have_attributes(content: /Paris/)]
      )
    end

    it "has token usage" do
      is_expected.to have_attributes(
        prompt_tokens: be_a(Integer),
        completion_tokens: be_a(Integer),
        total_tokens: be_a(Integer)
      )
    end
  end

  context "when given a function call",
          vcr: {cassette_name: "openai/responses/function_call"} do
    let(:bot) { LLM::Bot.new(provider, tools: [tool]) }
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.description("The command to run").required) }
        fn.define { |command:| {success: Kernel.system(command)} }
      end
    end

    before do
      allow(Kernel).to receive(:system).and_return("2024-01-01")
    end

    it "calls a function" do
      bot.respond "You are a bot that can run UNIX commands", role: :system
      bot.respond "What is the date?", role: :user
      expect(bot.functions).not_to be_empty
      bot.respond bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end
  end

  context "when given text streaming",
          vcr: {cassette_name: "openai/responses/text_streaming"} do
    let(:stream) { StringIO.new }

    subject do
      provider.responses.create(
        "Explain the theory of relativity in simple terms.",
        role: :user,
        stream:
      )
    end

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        choices: [have_attributes(content: include("relativity"))]
      )
    end

    it "streams text" do
      is_expected
      expect(stream.string).to include("relativity")
    end
  end

  context "when given a chat bot and an IO stream for responses",
          vcr: {cassette_name: "openai/responses/bot_text_stream"} do
    let(:params) { {stream:} }
    let(:stream) { StringIO.new }
    let(:bot) { LLM::Bot.new(provider, params) }
    let(:system_prompt) do
      "Keep your answers short and concise, and provide three answers to the three questions. " \
      "There should be one answer per line. " \
      "An answer should be a number, for example: 5. " \
      "Nothing else"
    end

    before do
      bot.respond do |prompt|
        prompt.user system_prompt
        prompt.user "What is 3+2 ?"
        prompt.user "What is 5+5 ?"
        prompt.user "What is 5+7 ?"
      end.to_a
    end

    context "with the contents of the IO" do
      subject { stream.string }
      it { is_expected.to match(%r_5\s*\n10\s*\n12\s*_) }
    end

    context "with the contents of the message" do
      subject { bot.messages.find(&:assistant?) }
      it { is_expected.to have_attributes(role: %r_(assistant|model)_, content: %r_5\s*\n10\s*\n12\s*_) }
    end
  end

  context "when given a chat bot and a tool stream for responses",
          vcr: {cassette_name: "openai/responses/bot_tool_stream"} do
    let(:params) { {stream: true, tools: [tool]} }
    let(:bot) { LLM::Bot.new(provider, params) }
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.required) }
        fn.define { |command:| {success: Kernel.system(command)} }
      end
    end

    before do
      bot.respond("You are a bot that can run UNIX system commands", role: :user)
      bot.respond("Hey, run the 'date' command", role: :user)
    end

    it "calls the function(s)" do
      expect(Kernel).to receive(:system).with("date").and_return("2024-01-01")
      bot.respond bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end
  end
end
