# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::DownloadFile LLM::Response::DownloadFile} class
  # represents the contents of a file that has been returned by a
  # provider. It wraps an IO object that can be used to read the file
  # contents.
  class Response::DownloadFile < Response
    ##
    # Returns a StringIO object
    # @return [StringIO]
    attr_accessor :file
  end
end
