# frozen_string_literal: true

RSpec.shared_examples "LLM::Chat: functions" do |dirname, options = {}|
  vcr = lambda do |basename|
    {vcr: {cassette_name: "#{dirname}/chat/#{basename}"}.merge(options)}
  end

  context "with a block", vcr.call("llm_function_block") do
    let(:params) { {tools: [tool]} }
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.required) }
        fn.define { {success: Kernel.system(_1.command)} }
      end
    end

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date", role: :user)
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
  end

  context "with a class", vcr.call("llm_function_class") do
    let(:params) { {tools: [tool]} }
    let(:tool) do
      LLM.function(:system) do |fn|
        fn.description "Runs system commands"
        fn.params { _1.object(command: _1.string.required) }
        fn.register(klass)
      end
    end
    let(:klass) do
      Class.new do
        def call(params)
          {success: Kernel.system(params.command)}
        end
      end
    end

    before do
      bot.chat("You are a bot that can run UNIX system commands", role: :user)
      bot.chat("Hey, tell me the date", role: :user)
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
