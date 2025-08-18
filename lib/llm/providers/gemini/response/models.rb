# frozen_string_literal: true

module LLM::Gemini::Response
  module Models
    include ::Enumerable
    def each(&)
      return enum_for(:each) unless block_given?
      models.each { yield(_1) }
    end

    def models
      body.models || []
    end
  end
end
