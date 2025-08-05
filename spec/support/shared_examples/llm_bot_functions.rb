# frozen_string_literal: true

RSpec.shared_examples "LLM::Bot: functions" do |dirname, options = {}|
  vcr = lambda do |basename|
    {vcr: {cassette_name: "#{dirname}/chat/#{basename}"}.merge(options)}
  end

  shared_examples "system function" do
    let(:params) { {tools: [tool]} }
    let(:returns) { bot.messages.select(&:tool_return?) }

    before do
      bot.chat do |prompt|
        prompt.user "You are a bot that can run UNIX system commands"
        prompt.user "Hey, run the 'date' command"
      end
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions[0].call
      expect(bot.functions).to be_empty
    end

    it "calls the function" do
      expect(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
      expect(bot.functions).to be_empty
    end

    it "includes a message with a return value" do
      allow(Kernel).to receive(:system).with("date").and_return(true)
      bot.chat bot.functions.map(&:call)
      expect(returns.size).to be(1)
    end
  end

  context "with a block", vcr.call("llm_function_block") do
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.required) }
        fn.define { |command:| {success: Kernel.system(command)} }
      end
    end
    include_examples "system function"
  end

  context "with a class", vcr.call("llm_function_class") do
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.required) }
        fn.register(klass)
      end
    end
    let(:klass) do
      Class.new do
        def call(command:)
          {success: Kernel.system(command)}
        end
      end
    end
    include_examples "system function"
  end

  context "with an empty array", vcr.call("llm_function_empty_array") do
    before { bot.chat("Hello! Nice to meet you", role: :user) }
    let(:params) { {} }

    it "does not raise an error" do
      bot.chat([])
      expect(bot.functions).to be_empty
    end
  end
end
