# frozen_string_literal: true

module LLM
  class Response::Vision < Response
    ##
    # @return [Array<URI>]
    #   Returns an array of image URIs
    def images
      parsed[:images]
    end

    private

    ##
    # @private
    # @return [Hash]
    #   Returns the parsed vision response from the provider
    def parsed
      @parsed ||= parse_vision(raw)
    end
  end
end
