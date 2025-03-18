# frozen_string_literal: true

class LLM::Ollama
  module Format
    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.map { {role: _1.role, content: format_content(_1.content)} }
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
