# frozen_string_literal: true

class LLM::Response::ModerationList
  ##
  # The {LLM::Response::ModerationList::Moderation Moderation}
  # class represents a moderation object that is returned by
  # the moderations interface.
  # @see LLM::Response::ModerationList
  # @see LLM::OpenAI::Moderations
  class Moderation
    ##
    # @param [Hash] moderation
    # @return [LLM::Response::ModerationList::Moderation]
    def initialize(moderation)
      @moderation = moderation
    end

    ##
    # Returns true if the moderation is flagged
    # @return [Boolean]
    def flagged?
      @moderation["flagged"]
    end

    ##
    # Returns the moderation categories
    # @return [Array<String>]
    def categories
      @moderation["categories"].filter_map { _2 ? _1 : nil }
    end

    ##
    # Returns the moderation scores
    # @return [Hash]
    def scores
      @moderation["category_scores"].select { categories.include?(_1) }
    end

    ##
    # @return [String]
    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} " \
      "categories=#{categories} " \
      "scores=#{scores}>"
    end
  end
end
