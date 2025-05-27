# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: openai" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.openai(key:) }
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :openai
    include_examples "LLM::Bot: text stream", :openai
    include_examples "LLM::Bot: tool stream", :openai
  end

  context LLM::Function do
    include_examples "LLM::Bot: functions", :openai
  end

  context LLM::File do
    include_examples "LLM::Bot: files", :openai
  end

  context JSON::Schema do
    include_examples "LLM::Bot: schema", :openai
  end
end
