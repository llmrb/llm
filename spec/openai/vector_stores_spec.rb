# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::VectorStores" do
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(key:) }

  context "when given a successful create operation",
          vcr: {cassette_name: "openai/vector_stores/successful_create"} do
    subject(:store) { provider.vector_stores.create(name: "test store") }
    after { provider.vector_stores.delete(vector: store) }

    it "is successful" do
      is_expected.to be_ok
    end

    it "includes created status" do
      is_expected.to have_attributes(
        "id" => instance_of(String),
        "object" => "vector_store"
      )
    end
  end

  context "when given a successful get operation",
          vcr: {cassette_name: "openai/vector_stores/successful_get"} do
    let(:store) { provider.vector_stores.create(name: "test store") }
    subject { provider.vector_stores.get(vector: store) }
    after { provider.vector_stores.delete(vector: store) }

    it "is successful" do
      is_expected.to be_ok
    end

    it "includes the store" do
      is_expected.to have_attributes(
        "id" => store.id,
        "name" => store.name
      )
    end
  end

  context "when given a successful delete operation",
          vcr: {cassette_name: "openai/vector_stores/successful_delete"} do
    let(:store) { provider.vector_stores.create(name: "test store") }
    subject { provider.vector_stores.delete(vector: store) }

    it "is successful" do
      is_expected.to be_ok
    end

    it "includes deleted status" do
      is_expected.to have_attributes(
        "deleted" => true
      )
    end
  end
end
