# frozen_string_literal: true

module LLM
  class Message
    ##
    # Returns the role of the message
    # @return [Symbol]
    attr_reader :role

    ##
    # Returns the content of the message
    # @return [String]
    attr_reader :content

    ##
    # Returns extra context associated with the message
    # @return [Hash]
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
    # Try to parse the content as JSON
    # @return [Hash]
    def content!
      JSON.parse(content)
    end

    ##
    # Returns true when the message is from the LLM
    # @return [Boolean]
    def assistant?
      role == "assistant" || role == "model"
    end

    ##
    # @return [Array<LLM::Function>]
    def functions
      @functions ||= tool_calls.map do |fn|
        function = LLM.functions[fn.name].dup
        function.tap { _1.arguments = fn.arguments }
      end
    end

    ##
    # @return [Boolean]
    #  Returns true when the message requests a function call
    def tool_call?
      tool_calls.any?
    end

    ##
    # Returns a string representation of the message
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "tool_call=#{tool_calls.any?} role=#{role.inspect} " \
      "content=#{content.inspect}>"
    end

    private

    def tool_calls
      @tool_calls ||= OpenStruct.from_hash(@extra[:tool_calls] || [])
    end
  end
end
