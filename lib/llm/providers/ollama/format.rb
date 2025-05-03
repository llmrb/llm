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
      case content
      when LLM::File
        if content.image?
          {content: "This message has an image associated with it", images: [content.to_b64]}
        else
          raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                         "is not an image, and therefore not supported by the " \
                                         "Ollama API"
        end
      when String
        {content:}
      when LLM::Message
        format_content(content.content)
      else
        raise LLM::Error::PromptError, "The given object (an instance of #{content.class}) " \
                                       "is not supported by the Ollama API"
      end
    end

    ##
    # @param [Array<LLM::Function>] tools
    #  The tools to format
    # @return [Hash]
    def format_tools(tools)
      return {} unless tools
      {tools: tools.map { _1.format(self) }}
    end
  end
end
