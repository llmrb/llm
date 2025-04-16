# frozen_string_literal: true

class LLM::Anthropic
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
      if URI === content
        [{
          type: :image,
          source: {type: :base64, media_type: LLM::File(content.to_s).mime_type, data: [content.to_s].pack("m0")}
        }]
      else
        content
      end
    end
  end
end
