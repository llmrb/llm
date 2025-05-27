# frozen_string_literal: true

RSpec.shared_examples "LLM::Bot: completions" do |dirname, options = {}|
  vcr = lambda do |basename|
    {vcr: {cassette_name: "#{dirname}/chat/#{basename}"}.merge(options)}
  end

  context "when given a thread of messages", vcr.call("llm_chat_completions") do
    let(:prompt) do
      "Keep your answers short and concise, and provide three answers to the three questions" \
      "There should be one answer per line" \
      "An answer should be a number, for example: 5" \
      "Nothing else"
    end

    subject(:message) { bot.messages.to_a[-1] }

    before do
      bot.chat prompt
      bot.chat "What is 3+2 ?"
      bot.chat "What is 5+5 ?"
      bot.chat "What is 5+7 ?"
    end

    it "maintains a conversation" do
      is_expected.to have_attributes(
        role: %r_\A(assistant|model)\z_,
        content: %r_5\s*\n10\s*\n12\s*_
      )
    end
  end
end
