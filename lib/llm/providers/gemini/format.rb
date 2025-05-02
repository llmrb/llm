# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  module Format
    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.map do
        if Hash === _1
          {role: _1[:role], parts: [format_content(_1[:content])]}
        else
          {role: _1.role, parts: [format_content(_1.content)]}
        end
      end
    end

    private

    ##
    # @param [String, Array, LLM::Response::File, LLM::File] content
    #  The content to format
    # @return [Hash]
    #  The formatted content
    def format_content(content)
      case content
      when Array
        content.map { format_content(_1) }
      when LLM::Response::File
        file = content
        {file_data: {mime_type: file.mime_type, file_uri: file.uri}}
      when LLM::File
        file = content
        {inline_data: {mime_type: file.mime_type, data: file.to_b64}}
      when String
        {text: content}
      when LLM::Message
        format_content(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the Gemini API"
      end
    end

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
