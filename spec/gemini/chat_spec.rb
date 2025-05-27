# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: gemini" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.gemini(key:) }
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :gemini, match_requests_on: [:method]
    include_examples "LLM::Chat: text stream", :gemini, match_requests_on: [:method]
    include_examples "LLM::Chat: tool stream", :gemini, match_requests_on: [:method]
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :gemini, match_requests_on: [:method]
  end

  context LLM::File do
    include_examples "LLM::Chat: files", :gemini, match_requests_on: [:method]
  end

  context JSON::Schema do
    include_examples "LLM::Chat: schema", :gemini, match_requests_on: [:method]
  end
end
