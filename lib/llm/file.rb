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
end

##
# @param [String] path
#  The path to a file
# @return [LLM::File]
def LLM.File(path)
  LLM::File.new(path)
end
