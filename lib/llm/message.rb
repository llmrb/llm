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
      @role = role.to_s
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

    ##
    # @param [Object] other
    #  The other object to compare
    # @return [Boolean]
    #  Returns true when the "other" object has the same role and content
    def ==(other)
      if other.respond_to?(:to_h)
        to_h == other.to_h
      else
        false
      end
    end
    alias_method :eql?, :==
  end
end
