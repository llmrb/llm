# frozen_string_literal: true

module LLM
  class Response::AudioTranscription < Response
    ##
    # Returns the text of the transcription
    # @return [String]
    attr_accessor :text
  end
end
