# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.openai(key:) }
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :openai
    include_examples "LLM::Chat: text stream", :openai
    include_examples "LLM::Chat: tool stream", :openai
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :openai
  end

  context LLM::File do
    include_examples "LLM::Chat: files", :openai
  end

  context JSON::Schema do
    include_examples "LLM::Chat: schema", :openai
  end
end
