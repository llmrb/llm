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
      when String
        {content:}
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        throw(:abort, {role: "tool", tool_call_id: content.id, content: JSON.dump(content.value)})
      when LLM::Object
        format_object(content)
      else
        prompt_error!(content)
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

    def format_object(object)
      case object.kind
      when :local_file then format_local_file(object.value)
      when :remote_file then prompt_error!(object)
      when :image_url then prompt_error!(object)
      else prompt_error!(object)
      end
    end

    def format_local_file(file)
      if file.image?
        {content: "This message has an image associated with it", images: [file.to_b64]}
      else
        raise LLM::PromptError, "The given local file (an instance of #{file.class}) " \
                                "is not an image, and therefore not supported by the " \
                                "Ollama API"
      end
    end

    def prompt_error!(object)
      if LLM::Object === object
        raise LLM::PromptError, "The given LLM::Object with kind '#{content.kind}' is not " \
                                "supported by the Ollama API"
      else
        raise LLM::PromptError, "The given object (an instance of #{object.class}) " \
                                "is not supported by the Ollama API"
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
