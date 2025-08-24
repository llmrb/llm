# frozen_string_literal: true

require_relative "setup"

RSpec.describe LLM::Mime do
  describe ".[]" do
    it "returns the correct mime type for a file extension" do
      expect(LLM::Mime[".png"]).to eq("image/png")
      expect(LLM::Mime[".jpg"]).to eq("image/jpeg")
      expect(LLM::Mime[".mp4"]).to eq("video/mp4")
      expect(LLM::Mime[".mp3"]).to eq("audio/mpeg")
      expect(LLM::Mime[".pdf"]).to eq("application/pdf")
      expect(LLM::Mime[".bin"]).to eq("application/octet-stream")
    end

    it "returns the correct mime type for a file path" do
      expect(LLM::Mime["image.png"]).to eq("image/png")
      expect(LLM::Mime["photo.jpg"]).to eq("image/jpeg")
      expect(LLM::Mime["video.mp4"]).to eq("video/mp4")
      expect(LLM::Mime["audio.mp3"]).to eq("audio/mpeg")
      expect(LLM::Mime["program.bin"]).to eq("application/octet-stream")
    end

    it "returns the correct mime type for an object with a path method" do
      file = double("File", path: "picture.png")
      expect(LLM::Mime[file]).to eq("image/png")
      file = double("File", path: "movie.mp4")
      expect(LLM::Mime[file]).to eq("video/mp4")
      file = double("File", path: "song.mp3")
      expect(LLM::Mime[file]).to eq("audio/mpeg")
      file = double("File", path: "report.pdf")
      expect(LLM::Mime[file]).to eq("application/pdf")
      file = double("File", path: "program.bin")
      expect(LLM::Mime[file]).to eq("application/octet-stream")
    end
  end

  describe ".types" do
    it "includes common mime types" do
      types = LLM::Mime.types
      expect(types).to include(".png" => "image/png")
      expect(types).to include(".jpg" => "image/jpeg")
      expect(types).to include(".mp4" => "video/mp4")
      expect(types).to include(".mp3" => "audio/mpeg")
    end
  end
end
