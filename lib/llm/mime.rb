# frozen_string_literal: true

##
# @private
class LLM::Mime
  ##
  # Lookup a mime type
  # @return [String, nil]
  def self.[](key)
    if key.respond_to?(:path)
      types[File.extname(key.path)]
    else
      types[key]
    end
  end

  ##
  # Returns a Hash of mime types
  # @return [Hash]
  def self.types
    @types ||= {
      # Images
      ".png" => "image/png",
      ".jpg" => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".webp" => "image/webp",

      # Videos
      ".flv" => "video/x-flv",
      ".mov" => "video/quicktime",
      ".mpeg" => "video/mpeg",
      ".mpg" => "video/mpeg",
      ".mp4" => "video/mp4",
      ".webm" => "video/webm",
      ".wmv" => "video/x-ms-wmv",
      ".3gp" => "video/3gpp",

      # Audio
      ".aac" => "audio/aac",
      ".flac" => "audio/flac",
      ".mp3" => "audio/mpeg",
      ".m4a" => "audio/mp4",
      ".mpga" => "audio/mpeg",
      ".opus" => "audio/opus",
      ".pcm" => "audio/L16",
      ".wav" => "audio/wav",
      ".weba" => "audio/webm",

      # Documents
      ".pdf" => "application/pdf",
      ".txt" => "text/plain"
    }
  end
end
