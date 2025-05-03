# frozen_string_literal: true

class LLM::Gemini
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
        formattable = Hash === message || !message.tool_call?
        formattable ? CompletionFormat.new(message).format : nil
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
        "generationConfig" => {
          "response_mime_type" => "application/json",
          "response_schema" => schema
        }
      }
    end

    ##
    # @param [Array<LLM::Function>] tools
    #  The tools to format
    # @return [Hash]
    def format_tools(tools)
      return {} unless tools
      functions = tools.grep(LLM::Function)
      {
        "tools" => {
          "functionDeclarations" => functions.map { _1.format(self) }
        }
      }
    end
  end
end
