# frozen_string_literal: true

RSpec.shared_examples "LLM::Chat: schema" do |dirname, options = {}|
  vcr = lambda do |basename|
    {vcr: options.merge({cassette_name: "#{dirname}/chat/#{basename}"})}
  end

  let(:params) { {schema:} }
  let(:llm) { provider }

  context "with an object", vcr.call("llm_schema_object") do
    let(:schema) { llm.schema.object(probability: llm.schema.integer.required) }
    subject { bot.messages.find(&:assistant?).content! }

    before do
      bot.chat "Does the earth orbit the sun?", role: :user
    end

    it "returns the probability" do
      is_expected.to match(
        "probability" => instance_of(Integer)
      )
    end
  end

  context "with an enum", vcr.call("llm_schema_enum") do
    let(:schema) { llm.schema.object(fruit: llm.schema.string.enum("apple", "pineapple", "orange")) }
    subject { bot.messages.find(&:assistant?).content!  }

    before do
      bot.chat "Your favorite fruit is pineapple", role: :user
      bot.chat "What fruit is your favorite?", role: :user
    end

    it "returns the favorite fruit" do
      is_expected.to match(
        "fruit" => "pineapple"
      )
    end
  end

  context "with an array", vcr.call("llm_schema_array") do
    let(:schema) { llm.schema.object(answers: llm.schema.array(llm.schema.integer.required).required) }
    subject { bot.messages.find(&:assistant?).content! }

    before do
      bot.chat "Answer all of my questions", role: :user
      bot.chat "Tell me the answer to ((5 + 5) / 2)", role: :user
      bot.chat "Tell me the answer to ((5 + 5) / 2) * 2", role: :user
      bot.chat "Tell me the answer to ((5 + 5) / 2) * 2 + 1", role: :user
    end

    it "returns the answers" do
      is_expected.to match(
        "answers" => [5, 10, 11]
      )
    end
  end
end
