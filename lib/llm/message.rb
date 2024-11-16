# frozen_string_literal: true

module LLM
  class Message
    ##
    # @return [Symbol]
    attr_reader :role

    ##
    # @return [String]
    attr_reader :content

    ##
    # @return [Hash]
    attr_reader :extra

    ##
    # @param [Symbol] role
    # @param [String] content
    # @param [Hash] extra
    # @return [LLM::Message]
    def initialize(role, content, extra = {})
      @role = role
      @content = content
      @extra = extra
    end

    ##
    # @return [OpenStruct]
    def logprobs
      return nil unless extra.key?(:logprobs)
      OpenStruct.from_hash(extra[:logprobs])
    end

    ##
    # @return [Hash]
    def to_h
      {role:, content:}
    end
  end
end
