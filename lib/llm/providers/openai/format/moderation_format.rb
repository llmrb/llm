# frozen_string_literal: true

module LLM::OpenAI::Format
  ##
  # @private
  class ModerationFormat
    ##
    # @param [String, URI, Array<String, URI>] inputs
    #  The inputs to format
    # @return [LLM::OpenAI::Format::ModerationFormat]
    def initialize(inputs)
      @inputs = inputs
    end

    ##
    # Formats the inputs for the OpenAI moderations API
    # @return [Array<Hash>]
    def format
      [*inputs].flat_map do |input|
        if String === input
          {type: :text, text: input}
        elsif URI === input
          {type: :image_url, url: input.to_s}
        else
          raise LLM::FormatError, "The given object (an instance of #{input.class}) " \
                                  "is not supported by OpenAI moderations API"
        end
      end
    end

    private

    attr_reader :inputs
  end
end
