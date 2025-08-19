# frozen_string_literal: true

module LLM::Anthropic::Format
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
    # Formats the message for the Anthropic chat completions API
    # @return [Hash]
    def format
      catch(:abort) do
        if Hash === message
          {role: message[:role], content: format_content(message[:content])}
        else
          format_message
        end
      end
    end

    private

    def format_message
      if message.tool_call?
        {role: message.role, content: message.extra[:original_tool_calls]}
      else
        {role: message.role, content: format_content(content)}
      end
    end

    ##
    # @param [String, URI] content
    #  The content to format
    # @return [String, Hash]
    #  The formatted content
    def format_content(content)
      case content
      when Hash
        content.empty? ? throw(:abort, nil) : [content]
      when Array
        content.empty? ? throw(:abort, nil) : content.flat_map { format_content(_1) }
      when URI
        [{type: :image, source: {type: "url", url: content.to_s}}]
      when File
        content.close unless content.closed?
        format_content(LLM.File(content.path))
      when LLM::File
        if content.image?
          [{type: :image, source: {type: "base64", media_type: content.mime_type, data: content.to_b64}}]
        elsif content.pdf?
          [{type: :document, source: {type: "base64", media_type: content.mime_type, data: content.to_b64}}]
        else
          raise LLM::PromptError, "The given object (an instance of #{content.class}) " \
                                  "is not an image or PDF, and therefore not supported by the " \
                                  "Anthropic API"
        end
      when LLM::Response
        if content.file?
          [{type: content.file_type, source: {type: :file, file_id: content.id}}]
        else
          prompt_error!(content)
        end
      when String
        [{type: :text, text: content}]
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        [{type: "tool_result", tool_use_id: content.id, content: [{type: :text, text: JSON.dump(content.value)}]}]
      else
        prompt_error!(content)
      end
    end

    def prompt_error!(content)
      raise LLM::PromptError, "The given object (an instance of #{content.class}) " \
                              "is not supported by the Anthropic API"
    end

    def message = @message
    def content = message.content
  end
end
