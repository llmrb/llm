# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  module Format
    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @param [Symbol] mode
    #  The mode to format the messages for
    # @return [Array<Hash>]
    def format(messages, mode)
      messages.map do
        if Hash === _1
          {role: _1[:role], content: format_content(_1[:content], mode)}
        else
          {role: _1.role, content: format_content(_1.content, mode)}
        end
      end
    end

    private

    ##
    # @param [String, URI] content
    #  The content to format
    # @return [String, Hash]
    #  The formatted content
    def format_content(content, mode)
      if mode == :complete
        format_complete(content)
      elsif mode == :response
        format_response(content)
      end
    end

    def format_complete(content)
      case content
      when Array
        content.flat_map { format_complete(_1) }
      when URI
        [{type: :image_url, image_url: {url: content.to_s}}]
      when LLM::File
        [{type: :image_url, image_url: {url: content.to_data_uri}}]
      when LLM::Response::File
        [{type: :file, file: {file_id: content.id}}]
      when String
        [{type: :text, text: content.to_s}]
      when LLM::Message
        format_complete(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the OpenAI chat completions API"
      end
    end

    def format_response(content)
      case content
      when Array
        content.flat_map { format_response(_1) }
      when LLM::Response::File
        [{type: :input_file, file_id: content.id}]
      when String
        [{type: :input_text, text: content.to_s}]
      when LLM::Message
        format_response(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the OpenAI responses API"
      end
    end
  end
end
