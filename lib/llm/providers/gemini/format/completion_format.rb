# frozen_string_literal: true

module LLM::Gemini::Format
  ##
  # @private
  class CompletionFormat
    ##
    # @param [LLM::Message, Hash] message
    #  The message to format
    def initialize(message)
      @message = message
    end

    ##
    # Formats the message for the Gemini chat completions API
    # @return [Hash]
    def format
      catch(:abort) do
        if Hash === message
          {role: message[:role], parts: format_content(message[:content])}
        elsif message.tool_call?
          {role: message.role, parts: message.extra[:original_tool_calls].map { {"functionCall" => _1} }}
        else
          {role: message.role, parts: format_content(message.content)}
        end
      end
    end

    def format_content(content)
      case content
      when Array
        content.empty? ? throw(:abort, nil) : content.flat_map { format_content(_1) }
      when LLM::Response
        format_response(content)
      when File
        content.close unless content.closed?
        format_content(LLM.File(content.path))
      when LLM::File
        file = content
        [{inline_data: {mime_type: file.mime_type, data: file.to_b64}}]
      when String
        [{text: content}]
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        [{text: JSON.dump(content.value)}]
      else
        prompt_error!(content)
      end
    end

    def format_response(response)
      if response.file?
        file = response
        [{file_data: {mime_type: file.mime_type, file_uri: file.uri}}]
      else
        prompt_error!(content)
      end
    end

    def prompt_error!(object)
      raise LLM::PromptError, "The given object (an instance of #{object.class}) " \
                              "is not supported by the Gemini API"
    end

    def message = @message
    def content = message.content
  end
end
