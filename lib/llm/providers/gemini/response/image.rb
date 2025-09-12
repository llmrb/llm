# frozen_string_literal: true

module LLM::Gemini::Response
  module Image
    ##
    # @return [Array<StringIO>]
    def images
      candidates.flat_map do |candidate|
        parts = candidate["content"]["parts"]
        parts.filter_map do
          data = _1.dig(:inlineData, :data)
          next unless data
          StringIO.new(data.unpack1("m0"))
        end
      end
    end

    ##
    # Returns one or more image URLs, or an empty array
    # @note
    #  Gemini's image generation API does not return URLs, so this method
    #  will always return an empty array.
    # @return [Array<String>]
    def urls = []

    ##
    # Returns one or more candidates, or an empty array
    # @return [Array<Hash>]
    def candidates = body.candidates || []
  end
end
