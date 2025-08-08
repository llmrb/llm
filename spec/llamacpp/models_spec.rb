# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::LlamaCpp::Models" do
  let(:provider) { LLM.llamacpp(host:) }
  let(:host) { ENV["LLAMACPP_HOST"] || "localhost" }

  context "when given a successful list operation",
          vcr: {cassette_name: "llamacpp/models/successful_list"} do
    subject(:response) { provider.models.all }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "returns a list of models" do
      expect(response.data).to all(be_a(LLM::Object))
    end
  end
end
