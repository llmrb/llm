# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama: embeddings" do
  let(:ollama) { LLM.ollama("") }

  context "when given a successful response", :success do
    subject(:response) { ollama.embed("Hello, world") }

    it "raises NotImplementedError" do
      expect { response }.to raise_error(NotImplementedError)
    end
  end
end
