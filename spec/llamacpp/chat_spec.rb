# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: llamacpp" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.llamacpp(host:) }
  let(:host) { ENV["LLAMACPP_HOST"] || "localhost" }
  let(:bot) { described_class.new(provider, params.merge(model: "qwen3")).lazy }
  let(:params) { {} }

  context LLM::Chat do
    include_examples "LLM::Chat: completions", :llamacpp
  end

  context LLM::Function do
    include_examples "LLM::Chat: functions", :llamacpp
  end

  context JSON::Schema do
    include_examples "LLM::Chat: schema", :llamacpp
  end
end
