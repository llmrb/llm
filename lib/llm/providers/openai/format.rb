# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  module Format
    require_relative "format/completion_format"
    require_relative "format/respond_format"
    require_relative "format/moderation_format"

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
    # @param [Hash] params
    # @return [Hash]
    def format_schema(params)
      return {} unless params and params[:schema]
      schema = params.delete(:schema)
      schema = schema.respond_to?(:object) ? schema.object : schema
      {
        response_format: {
          type: "json_schema",
          json_schema: {name: "JSONSchema", schema:}
        }
      }
    end

    ##
    # @param [Hash] params
    # @return [Hash]
    def format_tools(tools)
      if tools.nil? || tools.empty?
        {}
      else
        {tools: tools.map { _1.respond_to?(:format) ? _1.format(self) : _1 }}
      end
    end
  end
end
