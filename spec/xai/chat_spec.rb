# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: openai" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.xai(key:) }
  let(:key) { ENV["XAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params) }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :xai
    include_examples "LLM::Bot: text stream", :xai
    include_examples "LLM::Bot: tool stream", :xai
  end

  context LLM::Function do
    include_examples "LLM::Bot: functions", :xai
  end

  context LLM::File do
    include_examples "LLM::Bot: files", :xai
  end

  context JSON::Schema do
    include_examples "LLM::Bot: schema", :xai
  end
end
