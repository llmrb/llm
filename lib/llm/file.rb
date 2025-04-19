# frozen_string_literal: true

class LLM::File
  ##
  # @return [String]
  #  Returns the path to a file
  attr_reader :path

  def initialize(path)
    @path = path
  end

  ##
  # @return [String]
  #  Returns the MIME type of the file
  def mime_type
    LLM::Mime[File.extname(path)]
  end

  ##
  # @return [String]
  #  Returns true if the file is an image
  def image?
    mime_type.start_with?("image/")
  end

  ##
  # @return [String]
  #  Returns the file contents in base64
  def to_b64
    [File.binread(path)].pack("m0")
  end
end

##
# @param [String] path
#  The path to a file
# @return [LLM::File]
def LLM.File(path)
  LLM::File.new(path)
end
