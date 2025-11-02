# frozen_string_literal: true

module LLM::OpenAI::Format
  ##
  # @private
  class RespondFormat
    ##
    # @param [LLM::Message] message
    #  The message to format
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
      when LLM::Object
        case content.kind
        when :image_url
          [{type: :image_url, image_url: {url: content.value.to_s}}]
        when :remote_file
          format_file(content.value)
        when :local_file
          raise LLM::PromptError, "Local files are not directly supported for output formatting " \
                                  "in OpenAI's respond_format. Please use uploaded remote files."
        else
          prompt_error!(content)
        end
      when LLM::Response
        content.file? ? format_file(content) : prompt_error!(content)
      when String
        [{type: :input_text, text: content.to_s}]
      when LLM::Message
        format_content(content.content)
      else
        prompt_error!(content)
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
        {role: message.role, content: content.flat_map { format_content(_1) }}
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

    def prompt_error!(content)
      raise LLM::PromptError, "The given object (an instance of #{content.class}) " \
                              "is not supported by the OpenAI responses API"
    end
    def message = @message
    def content = message.content
    def returns = content.grep(LLM::Function::Return)
  end
end
