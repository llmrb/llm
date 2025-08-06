# frozen_string_literal: true

module LLM::DeepSeek::Format
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
    # Formats the message for the DeepSeek chat completions API
    # @return [Hash]
    def format
      catch(:abort) do
        if Hash === message
          {role: message[:role], content: format_content(message[:content])}
        elsif message.tool_call?
          {role: message.role, content: nil, tool_calls: message.extra[:original_tool_calls]}
        else
          format_message
        end
      end
    end

    private

    def format_content(content)
      case content
      when String
        content.to_s
      when LLM::Message
        format_content(content.content)
      when LLM::Function::Return
        throw(:abort, {role: "tool", tool_call_id: content.id, content: JSON.dump(content.value)})
      else
        raise LLM::PromptError, "The given object (an instance of #{content.class}) " \
                                "is not supported by the DeepSeek chat completions API"
      end
    end

    def format_message
      case content
      when Array
        format_array
      else
        {role: message.role, content: format_content(content)}
      end
    end

    def format_array
      if content.empty?
        nil
      elsif returns.any?
        returns.map { {role: "tool", tool_call_id: _1.id, content: JSON.dump(_1.value)} }
      else
        {role: message.role, content: content.flat_map { format_content(_1) }}
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
