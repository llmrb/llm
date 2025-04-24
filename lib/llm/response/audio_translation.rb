# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::AudioTranslation LLM::Response::AudioTranslation}
  # class represents an audio translation that has been returned by
  # a provider (eg OpenAI, Gemini, etc)
  class Response::AudioTranslation < Response
    ##
    # Returns the text of the translation
    # @return [String]
    attr_accessor :text
  end
end
