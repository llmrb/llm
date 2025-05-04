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
          {role: message[:role]}.merge(format_content(message[:content]))
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
      when Array
        content.empty? ? throw(:abort, nil) : content.flat_map { format_content(_1) }
      when URI
        [{type: :image, source: {type: "url", url: content.to_s}}]
      when LLM::File
        if content.image?
          [{type: :image, source: {type: "base64", media_type: content.mime_type, data: content.to_b64}}]
        else
          raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                          "is not an image, and therefore not supported by the " \
                                          "Anthropic API"
        end
      when String
        [{type: :text, text: content}]
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        {type: "tool_result", tool_use_id: content.id, content: content.value}
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the Anthropic API"
      end
    end

    def message = @message
    def content = message.content
  end
end
