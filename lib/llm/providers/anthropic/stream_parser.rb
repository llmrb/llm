# frozen_string_literal: true

class LLM::Anthropic
  ##
  # @private
  class StreamParser
    ##
    # Returns the fully constructed response body
    # @return [LLM::Object]
    attr_reader :body

    ##
    # @param [#<<] io An IO-like object
    # @return [LLM::Anthropic::StreamParser]
    def initialize(io)
      @body = LLM::Object.new(role: "assistant", content: [])
      @io = io
    end

    ##
    # @param [Hash] chunk
    # @return [LLM::Anthropic::StreamParser]
    def parse!(chunk)
      tap { merge!(chunk) }
    end

    private

    def merge!(chunk)
      if chunk["type"] == "message_start"
        merge_message!(chunk["message"])
      elsif chunk["type"] == "content_block_start"
        @body["content"][chunk["index"]] = chunk["content_block"]
      elsif chunk["type"] == "content_block_delta"
        if chunk["delta"]["type"] == "text_delta"
          @body.content[chunk["index"]]["text"] << chunk["delta"]["text"]
          @io << chunk["delta"]["text"] if @io.respond_to?(:<<)
        elsif chunk["delta"]["type"] == "input_json_delta"
          content = @body.content[chunk["index"]]
          if Hash === content["input"]
            content["input"] = chunk["delta"]["partial_json"]
          else
            content["input"] << chunk["delta"]["partial_json"]
          end
        end
      elsif chunk["type"] == "message_delta"
        merge_message!(chunk["delta"])
      elsif chunk["type"] == "content_block_stop"
        content = @body.content[chunk["index"]]
        if content["input"]
          content["input"] = JSON.parse(content["input"])
        end
      end
    end

    def merge_message!(message)
      message.each do |key, value|
        @body[key] = if value.respond_to?(:each_pair)
          merge_message!(value)
        else
          value
        end
      end
    end
  end
end
