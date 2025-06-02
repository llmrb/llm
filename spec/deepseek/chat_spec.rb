# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: openai" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.deepseek(key:) }
  let(:key) { ENV["DEEPSEEK_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params) }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :deepseek
    include_examples "LLM::Bot: text stream", :deepseek
    include_examples "LLM::Bot: tool stream", :deepseek
  end

  context LLM::Function do
    include_examples "LLM::Bot: functions", :deepseek
  end
end
