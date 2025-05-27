# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: ollama" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params).lazy }
  let(:params) { {} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :ollama
    include_examples "LLM::Chat: text stream", :ollama
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :ollama
  end

  context JSON::Schema do
    include_examples "LLM::Chat: schema", :ollama
  end
end
