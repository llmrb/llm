# frozen_string_literal: true

class LLM::Ollama
  ##
  # @private
  module Format
    require_relative "format/completion_format"

    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.filter_map do |message|
        CompletionFormat.new(message).format
      end
    end

    private

    ##
    # @param [Hash] params
    # @return [Hash]
    def format_tools(tools)
      return {} unless tools&.any?
      {tools: tools.map { _1.format(self) }}
    end
  end
end
