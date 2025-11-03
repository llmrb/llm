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
      when String
        [{text: content}]
      when LLM::Response
        format_remote_file(content)
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        [{functionResponse: {name: content.name, response: content.value}}]
      when LLM::Object
        format_object(content)
      else
        prompt_error!(content)
      end
    end

    def format_object(object)
      case object.kind
      when :image_url
        [{file_data: {mime_type: "image/*", file_uri: object.value.to_s}}]
      when :local_file
        file = object.value
        [{inline_data: {mime_type: file.mime_type, data: file.to_b64}}]
      when :remote_file
        format_remote_file(object.value)
      else
        prompt_error!(object)
      end
    end

    def format_remote_file(file)
      return prompt_error!(file) unless file.file?
      [{file_data: {mime_type: file.mime_type, file_uri: file.uri}}]
    end

    def prompt_error!(object)
      if LLM::Object === object
        raise LLM::PromptError, "The given LLM::Object with kind '#{content.kind}' is not " \
                                "supported by the Gemini API"
      else
        raise LLM::PromptError, "The given object (an instance of #{object.class}) " \
                                "is not supported by the Gemini API"
      end
    end

    def message = @message
    def content = message.content
  end
end
