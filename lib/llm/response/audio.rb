# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::Audio LLM::Response::Audio} class represents an
  # audio file that has been returned by a provider. It wraps an IO object
  # that can be used to read the contents of an audio stream (as binary data).
  class Response::Audio < Response
    ##
    # @return [StringIO]
    attr_accessor :audio
  end
end
