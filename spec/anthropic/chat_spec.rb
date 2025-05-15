# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: anthropic" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.anthropic(key:) }
  let(:key) { ENV["ANTHROPIC_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }

  context LLM::Function do
    include_examples "LLM::Chat: functions", :anthropic
  end

  context LLM::File do
    include_examples "LLM::Chat: files", :anthropic
  end
end
