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
    attr_reader :context

    ##
    # @param [Symbol] role
    # @param [String] content
    # @param [Hash] context
    # @return [LLM::Message]
    def initialize(role, content, context = {})
      @role = role
      @content = content
      @context = context
    end

    ##
    # @return [Hash]
    def to_h
      {role:, content:}
    end
  end
end
