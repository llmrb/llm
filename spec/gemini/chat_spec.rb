# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: gemini" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.gemini(key:) }
  let(:key) { ENV["GEMINI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params) }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :gemini, match_requests_on: [:method]
    include_examples "LLM::Bot: text stream", :gemini, match_requests_on: [:method]
    include_examples "LLM::Bot: tool stream", :gemini, match_requests_on: [:method]
  end

  context LLM::Function do
    include_examples "LLM::Bot: functions", :gemini, match_requests_on: [:method]
  end

  context LLM::File do
    include_examples "LLM::Bot: files", :gemini, match_requests_on: [:method]
  end

  context JSON::Schema do
    include_examples "LLM::Bot: schema", :gemini, match_requests_on: [:method]
  end
end
