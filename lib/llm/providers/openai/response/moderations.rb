# frozen_string_literal: true

module LLM::OpenAI::Response
  module Moderations
    ##
    # @return [Array<LLM::Response]
    def moderations
      @moderations ||= body.results.map { _1.extend(Moderation) }
    end
  end

  module Moderation
    ##
    # Returns true if the moderation is flagged
    # @return [Boolean]
    def flagged?
      body.flagged
    end

    ##
    # Returns the moderation categories
    # @return [Array<String>]
    def categories
      self["categories"].filter_map { _2 ? _1 : nil }
    end

    ##
    # Returns the moderation scores
    # @return [Hash]
    def scores
      self["category_scores"].select { |(key, _)| categories.include?(key) }.to_h
    end
  end
end
