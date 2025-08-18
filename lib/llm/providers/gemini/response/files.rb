# frozen_string_literal: true

module LLM::Gemini::Response
  module Files
    include ::Enumerable
    def each(&)
      return enum_for(:each) unless block_given?
      files.each { yield(_1) }
    end

    def files
      body.files || []
    end
  end
end