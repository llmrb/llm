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
    # Formats the message for the Ollama chat completions API
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
      when LLM::Object
        case content.kind
        when :image_url
          raise LLM::PromptError, "Ollama API does not directly support image URLs. Images must be provided as base64 encoded data."
        when :local_file
          file = content.value
          if file.image?
            {content: "This message has an image associated with it", images: [file.to_b64]}
          else
            raise LLM::PromptError, "The given local file (an instance of #{file.class}) " \
                                    "is not an image, and therefore not supported by the " \
                                    "Ollama API for local files"
          end
        when :remote_file
          raise LLM::PromptError, "Ollama API does not directly support remote file references. Images must be provided as base64 encoded data."
        else
          raise LLM::PromptError, "The given object (an instance of #{content.class} with kind #{content.kind}) " \
                                  "is not supported by the Ollama API"
        end
      when String
        {content:}
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        throw(:abort, {role: "tool", tool_call_id: content.id, content: JSON.dump(content.value)})
      else
        raise LLM::PromptError, "The given object (an instance of #{content.class}) " \
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
        content.flat_map { {role: message.role}.merge(format_content(_1)) }
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
