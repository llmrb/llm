# frozen_string_literal: true

class LLM::Ollama
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
          {role: _1[:role]}
            .merge!(_1)
            .merge!(format_content(_1[:content]))
        else
          {role: _1.role}.merge! format_content(_1.content)
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
      if LLM::File === content
        if content.image?
          {content: "This message has an image associated with it", images: [content.to_b64]}
        else
          raise TypeError, "'#{content.path}' was not recognized as an image file."
        end
      else
        {content:}
      end
    end
  end
end
