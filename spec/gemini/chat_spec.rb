# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: gemini" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.gemini(key:) }
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }

  context LLM::Function do
    include_examples "LLM::Chat: functions", :gemini, match_requests_on: [:method]
  end

  context LLM::File do
    include_examples "LLM::Chat: files", :gemini, match_requests_on: [:method]
  end
end
