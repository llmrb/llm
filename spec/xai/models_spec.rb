# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::XAI::Models" do
  let(:key) { ENV["XAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.xai(key:) }

  context "when given a successful list operation",
          vcr: {cassette_name: "xai/models/successful_list"} do
    subject(:response) { provider.models.all }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response)
    end

    it "returns a list of models" do
      expect(response.data).to all(be_a(LLM::Object))
    end
  end
end
