# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::AudioTranscription LLM::Response::AudioTranscription}
  # class represents an audio transcription that has been returned by
  # a provider (eg OpenAI, Gemini, etc)
  class Response::AudioTranscription < Response
    ##
    # Returns the text of the transcription
    # @return [String]
    attr_accessor :text
  end
end
