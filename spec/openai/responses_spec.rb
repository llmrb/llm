# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Responses" do
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(key:) }

  context "when given a successful create operation",
          vcr: {cassette_name: "openai/responses/successful_create"} do
    subject { provider.responses.create("Hello", role: :developer) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::Respond)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        outputs: [instance_of(LLM::Message)]
      )
    end
  end

  context "when given a successful get operation",
          vcr: {cassette_name: "openai/responses/successful_get"} do
    let(:response) { provider.responses.create("Hello", role: :developer) }
    subject { provider.responses.get(response) }

    it "is successful" do
      is_expected.to be_instance_of(LLM::Response::Respond)
    end

    it "has outputs" do
      is_expected.to have_attributes(
        outputs: [instance_of(LLM::Message)]
      )
    end
  end

  context "when given a successful delete operation",
          vcr: {cassette_name: "openai/responses/successful_delete"} do
    let(:response) { provider.responses.create("Hello", role: :developer) }
    subject { provider.responses.delete(response) }

    it "is successful" do
      is_expected.to have_attributes(
        deleted: true
      )
    end
  end
end
