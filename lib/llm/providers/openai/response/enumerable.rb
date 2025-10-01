# frozen_string_literal: true

module LLM::OpenAI::Response
  module Enumerable
    include ::Enumerable
    def each(&)
      return enum_for(:each) unless block_given?
      data.each { yield(_1) }
    end

    def empty?
      data.empty?
    end
  end
end
