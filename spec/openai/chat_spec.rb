# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Chat: openai" do
  let(:described_class) { LLM::Chat }
  let(:provider) { LLM.openai(key:) }
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:bot) { described_class.new(provider, params).lazy }

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
