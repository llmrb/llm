# frozen_string_literal: true

module LLM::OpenAI::Response
  module Enumerable
    include ::Enumerable
    def each(&)
      return enum_for(:each) unless block_given?
      data.each { yield(_1) }
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
