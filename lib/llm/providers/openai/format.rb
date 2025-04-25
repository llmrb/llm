# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  module Format
    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.map do
        if Hash === _1
          {role: _1[:role], content: format_content(_1[:content])}
        else
          {role: _1.role, content: format_content(_1.content)}
        end
      end
    end

    private

    ##
    # @param [String, URI] content
    #  The content to format
    # @return [String, Hash]
    #  The formatted content
    def format_content(content)
      case content
      when Array then content.flat_map { format_content(_1) }
      when URI then [{type: :image_url, image_url: {url: content.to_s}}]
      when LLM::Response::File then [{type: :input_file, file_id: content.id}]
      else [{type: :input_text, text: content.to_s}]
      end
    end
  end
end
