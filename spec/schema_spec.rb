# frozen_string_literal: true

require_relative "setup"

RSpec.describe LLM::Schema do
  context "when given a schema" do
    let(:all_properties) { [*required_properties, *unrequired_properties] }
    let(:required_properties) { %w[name age height] }
    let(:unrequired_properties) { %w[active location addresses] }

    let(:schema) do
      Class.new(LLM::Schema) do
        property :name, LLM::Schema::String, "name description", required: true
        property :age, LLM::Schema::Integer, "age description", required: true
        property :height, LLM::Schema::Number, "height description", required: true
        property :active, LLM::Schema::Boolean, "active description"
        property :location, LLM::Schema::Null, "location description"
        property :addresses, LLM::Schema::Array[LLM::Schema::String, LLM::Schema::Integer], "addresses description"
      end
    end

    it "has properties" do
      expect(schema.object.keys).to eq(all_properties)
    end

    it "sets properties" do
      all_properties.each { expect(schema.object[_1].description).to eq("#{_1} description") }
      required_properties.each { expect(schema.object[_1]).to be_required }
      unrequired_properties.each { expect(schema.object[_1]).to_not be_required }
    end
  end
end
