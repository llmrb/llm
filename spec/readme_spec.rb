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
        "[system] keep the answer concise",
        '[user] [{:type=>:image_url, :image_url=>{:url=>"https://upload.wikimedia.org/wikipedia/commons/b/be/Red_eyed_tree_frog_edit2.jpg"}}]',
        "[user] What is the frog's name?",
        "[user] What is the frog's habitat?",
        "[user] What is the frog's diet?",
        "[assistant] The frog in the image is likely a **Red-Eyed Tree Frog**.",
        "",
        "**Habitat:** Typically found in tropical rainforests near water bodies like ponds and streams.",
        "",
        "**Diet:** Primarily eats insects, including crickets, moths, and other small invertebrates.\n"
      ].map(&:strip)
    end

    it "is successful" do
      is_expected.to be_success
    end

    it "emits output" do
      expect(actual_conversation).to eq(expected_conversation)
    end
  end

  def webmock(example)
    File.join(Dir.getwd, "share", "llm", "webmocks", example)
  end

  def readme_example(example)
    File.join(Dir.getwd, "share", "llm", "examples", example)
  end
end
