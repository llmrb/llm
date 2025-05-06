# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::Ollama::Models" do
  let(:provider) { LLM.ollama(host:) }
  let(:host) { ENV["OLLAMA_HOST"] || "localhost" }

  context "when given a successful list operation",
          vcr: {cassette_name: "ollama/models/successful_list"} do
    subject { provider.models.all }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::ModelList)
    end

    it "returns a list of models" do
      expect(subject.models).to all(be_a(LLM::Model))
    end
  end
end
