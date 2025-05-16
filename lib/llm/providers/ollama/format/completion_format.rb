# frozen_string_literal: true

module LLM::Ollama::Format
  ##
  # @private
  class CompletionFormat
    ##
    # @param [LLM::Message] message
    #  The message to format
    def initialize(message)
      @message = message
    end

    ##
    # Returns the message for the Ollama chat completions API
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
      when LLM::Function::Return
        throw(:abort, {role: "tool", tool_call_id: content.id, content: JSON.dump(content.value)})
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
      if content.empty?
        nil
      elsif returns.any?
        returns.map { {role: "tool", tool_call_id: _1.id, content: JSON.dump(_1.value)} }
      else
        content.flat_map { {role: message.role }.merge(format_content(_1)) }
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
