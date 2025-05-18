# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: llamacpp" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.llamacpp(host:) }
  let(:host) { ENV["LLAMACPP_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params.merge(model: "qwen3")).lazy }
  let(:params) { {} }
  vcr = lambda { {vcr: {cassette_name: "llamacpp/chat/#{_1}"}} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :llamacpp

    context "with streams" do
      include_examples "LLM::Chat: text stream", :llamacpp

      context "when tool calls are not supported", vcr.call("llm_chat_stream_tool") do
        before { bot.chat "Run the tool" }

        let(:params) { {stream: true, tools: [tool]} }
        let(:tool) do
          LLM.function(:system) do |fn|
            fn.description "Runs system commands"
            fn.params { _1.object(command: _1.string.required) }
            fn.define { {success: Kernel.system(_1.command)} }
          end
        end

        it "emits an error" do
          bot.messages.to_a
          expect(false).to be_true
        rescue => ex
          expect(ex.message).to match(/Cannot use tools with stream/)
        end
      end
    end
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :llamacpp
  end

  context JSON::Schema do
    include_examples "LLM::Chat: schema", :llamacpp
  end
end
