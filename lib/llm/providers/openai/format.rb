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
        file = content
        if file.image?
          [{type: :image_url, image_url: {url: file.to_data_uri}}]
        else
          [{type: :file, file: {filename: file.basename, file_data: file.to_data_uri}}]
        end
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
        file = LLM::File(content.filename)
        if file.image?
          [{type: :input_image, file_id: content.id}]
        else
          [{type: :input_file, file_id: content.id}]
        end
      when String
        [{type: :input_text, text: content.to_s}]
      when LLM::Message
        format_response(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the OpenAI responses API"
      end
    end

    ##
    # @param [JSON::Schema] schema
    #  The schema to format
    # @return [Hash]
    def format_schema(schema)
      return {} unless schema
      {
        response_format: {
          type: "json_schema",
          json_schema: {name: "JSONSchema", schema:}
        }
      }
    end

    ##
    # @param [Array<LLM::Function>] tools
    #  The tools to format
    # @return [Hash]
    def format_tools(tools)
      return {} unless tools
      {tools: tools.map { format_tool(_1) }}
    end
  end
end
