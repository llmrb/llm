# frozen_string_literal: true

module LLM::Anthropic::Response
  module Enumerable
    include ::Enumerable

    def each(&)
      return enum_for(:each) unless block_given?
      data.each { yield(_1) }
    end

    ##
    # Returns an element, or a slice, or nil
    # @return [Object, Array<Object>, nil]
    def [](*pos, **kw)
      data[*pos, **kw]
    end

    ##
    # @return [Boolean]
    def empty?
      data.empty?
    end

    ##
    # @return [Integer]
    def size
      data.size
    end
  end
end
