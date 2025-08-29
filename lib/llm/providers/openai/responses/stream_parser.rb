# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  class Responses::StreamParser
    ##
    # Returns the fully constructed response body
    # @return [LLM::Object]
    attr_reader :body

    ##
    # @param [#<<] io An IO-like object
    # @return [LLM::OpenAI::Responses::StreamParser]
    def initialize(io)
      @body = LLM::Object.new(output: []) # Initialize with an empty output array
      @io = io
    end

    ##
    # @param [Hash] chunk
    # @return [LLM::OpenAI::Responses::StreamParser]
    def parse!(chunk)
      tap { handle_event(chunk) }
    end

    private

    def handle_event(chunk)
      case chunk["type"]
      when "response.created"
        chunk.each do |k, v|
          next if k == "type"
          @body[k] = v
        end
        @body.output ||= []
      when "response.output_item.added"
        output_index = chunk["output_index"]
        item = LLM::Object.from_hash(chunk["item"])
        @body.output[output_index] = item
        @body.output[output_index].content ||= []
      when "response.content_part.added"
        output_index = chunk["output_index"]
        content_index = chunk["content_index"]
        part = LLM::Object.from_hash(chunk["part"])
        @body.output[output_index] ||= LLM::Object.new(content: [])
        @body.output[output_index].content ||= []
        @body.output[output_index].content[content_index] = part
      when "response.output_text.delta"
        output_index = chunk["output_index"]
        content_index = chunk["content_index"]
        delta_text = chunk["delta"]
        output_item = @body.output[output_index]
        if output_item&.content
          content_part = output_item.content[content_index]
          if content_part && content_part.type == "output_text"
            content_part.text ||= ""
            content_part.text << delta_text
            @io << delta_text if @io.respond_to?(:<<)
          end
        end
      when "response.output_item.done"
        output_index = chunk["output_index"]
        item = LLM::Object.from_hash(chunk["item"])
        @body.output[output_index] = item
      when "response.content_part.done"
        output_index = chunk["output_index"]
        content_index = chunk["content_index"]
        part = LLM::Object.from_hash(chunk["part"])
        @body.output[output_index] ||= LLM::Object.new(content: [])
        @body.output[output_index].content ||= []
        @body.output[output_index].content[content_index] = part
      end
    end
  end
end
