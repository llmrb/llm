# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: ollama" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params).lazy }

  context LLM::Function do
    include_examples "LLM::Chat: functions", :ollama
  end
end
