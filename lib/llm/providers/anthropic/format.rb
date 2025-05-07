# frozen_string_literal: true

class LLM::Anthropic
  ##
  # @private
  module Format
    require_relative "format/completion_format"

    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.filter_map do
        CompletionFormat.new(_1).format
      end
    end

    private

    ##
    # @param [Hash] params
    # @return [Hash]
    def format_tools(params)
      return {} unless params and params[:tools]&.any?
      tools = params[:tools]
      {tools: tools.map { _1.format(self) }}
    end
  end
end
