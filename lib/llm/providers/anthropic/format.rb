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
      case content
      when Array
        content.flat_map { format_content(_1) }
      when URI
        [{ type: :image, source: {type: "url", url: content.to_s} }]
      when LLM::File
        if content.image?
          [ {type: :image, source: {type: "base64", media_type: content.mime_type, data: content.to_b64} }]
        else
          raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                          "is not an image, and therefore not supported by the " \
                                          "Anthropic API"
        end
      when String
        [{type: :text, text: content}]
      when LLM::Message
        format_content(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the Anthropic API"
      end
    end
  end
end
