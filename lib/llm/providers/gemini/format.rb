# frozen_string_literal: true

class LLM::Gemini
  module Format
    ##
    # @param [Array<LLM::Message>] messages
    #  The messages to format
    # @return [Array<Hash>]
    def format(messages)
      messages.map { {role: _1.role, parts: [format_content(_1.content)]} }
    end

    private

    ##
    # @param [String, LLM::File] content
    #  The content to format
    # @return [String, Hash]
    #  The formatted content
    def format_content(content)
      if LLM::File === content
        file = content
        {
          inline_data: {mime_type: file.mime_type, data: [File.binread(file.path)].pack("m0")}
        }
      else
        {text: content}
      end
    end
  end
end
