# frozen_string_literal: true

module LLM::Ollama::Format
  ##
  # @private
  class CompletionFormat
    def initialize(message)
      @message = message
    end

    ##
    # @param [LLM::Message] message
    #  The message to format
    # @return [Hash]
    def format
      if Hash === message
        {role: message[:role]}.merge(format_content(message[:content]))
      else
        format_message
      end
    end

    private

    def format_content(content)
      case content
      when LLM::File
        if content.image?
          {content: "This message has an image associated with it", images: [content.to_b64]}
        else
          raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                         "is not an image, and therefore not supported by the " \
                                         "Ollama API"
        end
      when String
        {content:}
      when LLM::Message
        format_content(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the Ollama API"
      end
    end

    def format_message
      case content
      when Array
        format_array
      else
        {role: message.role}.merge(format_content(content))
      end
    end

    def format_array
      if returns.any?
        returns.map { {role: "tool", tool_call_id: _1.id, content: JSON.dump(_1.value)} }
      else
        {role: message.role, content: message.content.map { format_content(content) }}
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
