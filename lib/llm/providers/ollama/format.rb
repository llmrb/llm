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
        [{type: :image_url, image_url: {url: content.to_s}}]
      else
        content
      end
    end
  end
end
