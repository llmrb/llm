# frozen_string_literal: true

module LLM::OpenAI::Format
  class RespondFormat
    def initialize(message)
      @message = message
    end

    def format
      format_message
    end

    private

    def format_content(content)
      case content
      when Array
        content.flat_map { format_content(_1) }
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
      if returns.any?
        returns.map { { type: "function_call_output", call_id: _1.id, output: JSON.dump(_1.value) } }
      else
        {role: message.role, content: message.content.map { format_content(content) }}
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
