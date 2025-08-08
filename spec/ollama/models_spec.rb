# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama::Models" do
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }

  context "when given a successful list operation",
          vcr: {cassette_name: "ollama/models/successful_list"} do
    subject(:models) { provider.models.all }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "returns a list of models" do
      expect(models).to all(be_a(LLM::Object))
    end
  end
end
