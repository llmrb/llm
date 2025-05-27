# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Bot: ollama" do
  let(:described_class) { LLM::Bot }
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Bot do
    include_examples "LLM::Bot: completions", :ollama
    include_examples "LLM::Bot: text stream", :ollama
  end

  context LLM::Function do
    include_examples "LLM::Bot: functions", :ollama
  end

  context JSON::Schema do
    include_examples "LLM::Bot: schema", :ollama
  end
end
