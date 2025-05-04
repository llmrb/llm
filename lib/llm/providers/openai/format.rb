# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  module Format
    require_relative "format/completion_format"
    require_relative "format/respond_format"

    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @param [Symbol] mode
    #  The mode to format the messages for
    # @return [Array<Hash>]
    def format(messages, mode)
      messages.filter_map do |message|
        if mode == :complete
          CompletionFormat.new(message).format
        else
          RespondFormat.new(message).format
        end
      end
    end

    private

    ##
    # @param [JSON::Schema] schema
    #  The schema to format
    # @return [Hash]
    def format_schema(schema)
      return {} unless schema
      {
        response_format: {
          type: "json_schema",
          json_schema: {name: "JSONSchema", schema:}
        }
      }
    end

    ##
    # @param [Array<LLM::Function>] tools
    #  The tools to format
    # @return [Hash]
    def format_tools(tools)
      return {} unless tools
      {tools: tools.map { _1.format(self) }}
    end
  end
end
