# frozen_string_literal: true

RSpec.shared_examples "LLM::Bot: schema" do |dirname, options = {}|
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
    subject { bot.messages.find(&:assistant?).content!  }

    let(:schema) { llm.schema.object(fruit:) }
    let(:fruit) { llm.schema.string.enum(*fruits).required.description("The favorite fruit") }
    let(:fruits) { ["apple", "pineapple", "orange"] }

    let(:prompt) do
      bot.build_prompt do
        _1.user "Your favorite fruit is pineapple"
        _1.user"What fruit is your favorite?"
      end
    end

    before { bot.chat(prompt) }

    it "returns the favorite fruit" do
      is_expected.to match(
        "fruit" => "pineapple"
      )
    end
  end

  context "with an array", vcr.call("llm_schema_array") do
    subject { bot.messages.find(&:assistant?).content! }

    let(:schema) { llm.schema.object(answers:) }
    let(:answers) { llm.schema.array(llm.schema.integer.required).required.description("The answer to two questions") }
    let(:prompt) do
      bot.build_prompt do
        _1.user "Answer all of my questions"
        _1.user "Tell me the answer to 5 + 5"
        _1.user "Tell me the answer to 5 + 7"
      end
    end

    before { bot.chat(prompt) }

    it "returns the answers" do
      is_expected.to match(
        "answers" => [10, 12]
      )
    end
  end
end
