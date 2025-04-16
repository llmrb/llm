# frozen_string_literal: true

module LLM
  class Message
    ##
    # @return [Symbol]
    #  The role of the message
    attr_reader :role

    ##
    # @return [String]
    #  The content of the message
    attr_reader :content

    ##
    # @return [Hash]
    #  Extra context associated with the message
    attr_reader :extra

    ##
    # Returns a new message
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
    # Returns logprobs if available, otherwise nil
    # @return [OpenStruct, nil]
    def logprobs
      return nil unless extra.key?(:logprobs)
      OpenStruct.from_hash(extra[:logprobs])
    end

    ##
    # Returns a hash representation of the message
    # @return [Hash]
    def to_h
      {role:, content:}
    end

    ##
    # Returns true when two objects have the same role and content
    # @param [Object] other
    #  The other object to compare
    # @return [Boolean]
    def ==(other)
      if other.respond_to?(:to_h)
        to_h == other.to_h
      else
        false
      end
    end
    alias_method :eql?, :==

    ##
    # Returns a string representation of the message
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "role=#{role.inspect} content=#{content.inspect}>"
    end
  end
end
