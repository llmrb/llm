# frozen_string_literal: true

require "setup"

RSpec.describe "LLM::OpenAI::Moderations" do
  let(:key) { ENV["OPENAI_SECRET"] || "TOKEN" }
  let(:provider) { LLM.openai(key:) }

  context "when given a string",
          vcr: {cassette_name: "openai/moderations/create_1"} do
    let(:response) { provider.moderations.create(input: "I hate you") }
    subject(:moderation) { response.moderations.first }

    it "has categories" do
      expect(moderation.categories).to eq([:harassment])
    end

    it "has scores" do
      expect(moderation.scores).to match(harassment: instance_of(Float))
    end
  end
end
