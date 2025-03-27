# frozen_string_literal: true

require "setup"
require "test/cmd"

RSpec.describe "The README examples" do
  before { ENV["key"] = key }
  after { ENV["key"] = nil }
  let(:key) { "" }

  context "when given the lazy conversation example" do
    subject(:command) do
      cmd RbConfig.ruby,
        "-Ilib",
        "-r", webmock("lazy_conversation.rb"),
        readme_example("lazy_conversation.rb")
    end

    let(:actual_conversation) do
      command.stdout.each_line.map(&:strip)
    end

    let(:expected_conversation) do
      [
        "[system] You are my math assistant.",
        "I will provide you with (simple) equations." ,
        "You will provide answers in the format \"The answer to <equation> is <answer>\".",
        "I will provide you a set of messages. Reply to all of them.",
        "A message is considered unanswered if there is no corresponding assistant response.",

        "[user] Tell me the answer to 5 + 15",
        "[user] Tell me the answer to (5 + 15) * 2",
        "[user] Tell me the answer to ((5 + 15) * 2) / 10",

        "[assistant] The answer to 5 + 15 is 20.",
        "The answer to (5 + 15) * 2 is 40.",
        "The answer to ((5 + 15) * 2) / 10 is 4.",

      ].map(&:strip)
    end

    it "is successful" do
      is_expected.to be_success
    end

    it "emits output" do
      expect(join(actual_conversation)).to eq(join(expected_conversation))
    end
  end

  def webmock(example)
    File.join(Dir.getwd, "share", "llm", "webmocks", example)
  end

  def readme_example(example)
    File.join(Dir.getwd, "share", "llm", "examples", example)
  end

  def join(lines)
    lines.reject(&:empty?).join("\n")
  end
end
