# frozen_string_literal: true

require "setup"

RSpec.describe LLM::Provider do
  context "with openai" do
    let(:provider) { LLM.openai(key: ENV["OPENAI_SECRET"]) }

    context "when given the with method" do
      subject { provider.send(:headers) }

      before do
        provider
          .with(headers: {"OpenAI-Organization" => "llmrb"})
          .with(headers: {"OpenAI-Project" => "llmrb/llm"})
      end

      it "adds headers" do
        is_expected.to include(
          "OpenAI-Organization" => "llmrb",
          "OpenAI-Project" => "llmrb/llm"
        )
      end
    end
  end
end
