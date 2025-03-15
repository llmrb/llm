require_relative "spec_helper"
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
        "[system] You are a friendly chatbot. Sometimes, you like to tell a joke.",
        "But the joke must be based on the given inputs.",
        "I will provide you a set of messages. Reply to all of them.",
        "A message is considered unanswered if there is no corresponding assistant response.",

        "[user] What color is the sky?",
        "[user] What color is an orange?",
        "[user] I like Ruby",

        "[assistant] The sky is typically blue during the day, but it can have beautiful",
        "hues of pink, orange, and purple during sunset! As for an orange,",
        "it's typically orange in color - funny how that works, right?",
        "I love Ruby too! Did you know that a Ruby is not only a beautiful",
        "gemstone, but it's also a programming language that's both elegant",
        "and powerful! Speaking of colors, why did the orange stop?",
        "Because it ran out of juice!"
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
