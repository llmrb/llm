# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.deepseek(key:) }
  let(:key) { ENV["DEEPSEEK_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :deepseek
    include_examples "LLM::Chat: text stream", :deepseek
    include_examples "LLM::Chat: tool stream", :deepseek
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :deepseek
  end
end
