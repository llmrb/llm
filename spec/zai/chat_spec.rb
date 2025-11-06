# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: openai" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.zai(key:) }
  let(:key) { ENV["ZAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params) }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :zai
    include_examples "LLM::Bot: text stream", :zai
    include_examples "LLM::Bot: tool stream", :zai
  end

  context LLM::Function do
    # include_examples "LLM::Bot: functions", :zai
  end
end
