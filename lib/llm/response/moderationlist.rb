# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::ModerationList LLM::Response::ModerationList} class
  # represents a response from the moderations API. It is an Enumerable that
  # yields an instance of {LLM::Response::ModerationList::Moderation LLM::Response::ModerationList::Moderation},
  # and each moderation object contains the categories and scores for a given
  # input.
  # @see LLM::OpenAI::Moderations LLM::OpenAI::Moderations
  class Response::ModerationList < Response
    require_relative "moderationlist/moderation"
    include Enumerable

    ##
    # Returns the moderation ID
    # @return [String]
    def id
      parsed[:id]
    end

    ##
    # Returns the moderation model
    # @return [String]
    def model
      parsed[:model]
    end

    ##
    # Yields each moderation object
    # @yieldparam [OpenStruct] moderation
    # @yieldreturn [void]
    # @return [void]
    def each(&)
      moderations.each(&)
    end

    private

    def parsed
      @parsed ||= parse_moderation_list(body)
    end

    ##
    # Returns an array of moderation objects
    # @return [Array<OpenStruct>]
    def moderations
      parsed[:moderations]
    end
  end
end
