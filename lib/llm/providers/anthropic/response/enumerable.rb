# frozen_string_literal: true

module LLM::Anthropic::Response
  module Enumerable
    include ::Enumerable
    def each(&)
      return enum_for(:each) unless block_given?
      data.each { yield(_1) }
    end
  end
end
