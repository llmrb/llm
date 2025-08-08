# frozen_string_literal: true

##
# The {LLM::File LLM::File} class represents a local file. It can
# be used as a prompt with certain providers (eg: Ollama, Gemini),
# and as an input with certain methods
class LLM::File
  ##
  # @return [String]
  #  Returns the path to the file
  attr_reader :path

  def initialize(path)
    @path = path
  end

  ##
  # @return [String]
  #  Returns basename of the file
  def basename
    File.basename(path)
  end

  ##
  # @return [String]
  #  Returns the MIME type of the file
  def mime_type
    LLM::Mime[File.extname(path)]
  end

  ##
  # @return [Boolean]
  #  Returns true if the file is an image
  def image?
    mime_type.start_with?("image/")
  end

  ##
  # @return [Boolean]
  #  Returns true if the file is a PDF document
  def pdf?
    mime_type == "application/pdf"
  end

  ##
  # @return [Integer]
  #  Returns the size of the file in bytes
  def bytesize
    File.size(path)
  end

  ##
  # @return [String]
  #  Returns the file contents in base64
  def to_b64
    [File.binread(path)].pack("m0")
  end

  ##
  # @return [String]
  #  Returns the file contents in base64 URL format
  def to_data_uri
    "data:#{mime_type};base64,#{to_b64}"
  end

  ##
  # @return [File]
  #  Yields an IO object suitable to be streamed
  def with_io
    io = File.open(path, "rb")
    yield(io)
  ensure
    io.close
  end
end

##
# @param [String] path
#  The path to a file
# @return [LLM::File]
def LLM.File(path)
  case path
  when LLM::File, LLM::Response then path
  else LLM::File.new(path)
  end
end
