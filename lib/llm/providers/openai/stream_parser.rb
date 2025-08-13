# frozen_string_literal: true

class LLM::OpenAI
  ##
  # @private
  class StreamParser
    ##
    # Returns the fully constructed response body
    # @return [LLM::Object]
    attr_reader :body

    ##
    # @return [LLM::OpenAI::Chunk]
    def initialize(io)
      @body = LLM::Object.new
      @io = io
    end

    ##
    # @param [Hash] chunk
    # @return [LLM::OpenAI::Chunk]
    def parse!(chunk)
      tap { merge!(chunk) }
    end

    private

    def merge!(chunk)
      chunk.each do |key, value|
        if key == "choices"
          @body["choices"] ||= []
          merge_choices!(value)
        else
          @body[key] = value
        end
      end
    end

    def merge_choices!(choices)
      choices.each do |choice|
        if @body.choices[choice["index"]]
          target = @body["choices"][choice["index"]]["message"]
          delta = choice["delta"]
          delta.each do |key, value|
            if target[key]
              if key == "content"
                target[key] << value
                @io << value if @io.respond_to?(:<<)
              elsif key == "tool_calls"
                merge_tools!(target, value)
              else
                target[key] = value
              end
            else
              @io << value if @io.respond_to?(:<<)
              target[key] = value
            end
          end
        else
          target = {"message" => {"role" => "assistant"}}
          @body["choices"][choice["index"]] = target
          target["message"].merge!(choice["delta"])
        end
      end
    end

    def merge_tools!(target, tools)
      tools.each.with_index do |toola, index|
        toolb = target["tool_calls"][index]
        if toolb
          toola["function"].each { toolb["function"][_1] << _2 }
        else
          target["tool_calls"][index] = toola
        end
      end
    end
  end
end
