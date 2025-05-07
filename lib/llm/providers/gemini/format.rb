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
        CompletionFormat.new(message).format
      end
    end

    private

    ##
    # @param [Hash] params
    # @return [Hash]
    def format_schema(params)
      return {} unless params and params[:schema]
      schema = params.delete(:schema)
      {generationConfig: {response_mime_type: "application/json", response_schema: schema}}
    end

    ##
    # @param [Hash] params
    # @return [Hash]
    def format_tools(params)
      return {} unless params and params[:tools]&.any?
      functions = params.delete(:tools).grep(LLM::Function)
      {tools: {functionDeclarations: functions.map { _1.format(self) }}}
    end
  end
end
