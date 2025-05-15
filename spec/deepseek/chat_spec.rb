# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.deepseek(key:) }
  let(:key) { ENV["DEEPSEEK_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }

  context LLM::Function do
    include_examples "LLM::Chat: functions", :deepseek
  end
end
