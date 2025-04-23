# frozen_string_literal: true

module LLM
  class Response::AudioTranslation < Response
    ##
    # Returns the text of the translation
    # @return [String]
    attr_accessor :text
  end
end
