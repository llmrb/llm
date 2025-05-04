# frozen_string_literal: true

module LLM::OpenAI::Format
  ##
  # @private
  class RespondFormat
    def initialize(message)
      @message = message
    end

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

    def format_content(content)
      case content
      when LLM::Response::File
        format_file(content)
      when String
        [{type: :input_text, text: content.to_s}]
      when LLM::Message
        format_content(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the OpenAI responses API"
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
        returns.map { {type: "function_call_output", call_id: _1.id, output: JSON.dump(_1.value)} }
      else
        {role: message.role, content: content.map { format_content(_1) }}
      end
    end

    def format_file(content)
      file = LLM::File(content.filename)
      if file.image?
        [{type: :input_image, file_id: content.id}]
      else
        [{type: :input_file, file_id: content.id}]
      end
    end

    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
