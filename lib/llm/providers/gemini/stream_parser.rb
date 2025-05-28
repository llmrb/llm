# frozen_string_literal: true

class LLM::Gemini
  ##
  # @private
  class StreamParser
    ##
    # Returns the fully constructed response body
    # @return [LLM::Object]
    attr_reader :body

    ##
    # @param [#<<] io An IO-like object
    # @return [LLM::Gemini::StreamParser]
    def initialize(io)
      @body = LLM::Object.new
      @io = io
    end

    ##
    # @param [Hash] chunk
    # @return [LLM::Gemini::StreamParser]
    def parse!(chunk)
      tap { merge!(chunk) }
    end

    private

    def merge!(chunk)
      chunk.each do |key, value|
        if key == "candidates"
          @body.candidates ||= []
          merge_candidates!(value)
        else
          @body[key] = value
        end
      end
    end

    def merge_candidates!(candidates)
      candidates.each.with_index do |candidate, i|
        if @body.candidates[i].nil?
          merge_one(@body.candidates, candidate, i)
        else
          merge_two(@body.candidates, candidate, i)
        end
      end
    end

    def merge_one(candidates, candidate, i)
      candidate
        .dig("content", "parts")
        &.filter_map { _1["text"] }
        &.each { @io << _1 if @io.respond_to?(:<<) }
      candidates[i] = candidate
    end

    def merge_two(candidates, candidate, i)
      parts = candidates[i].dig("content", "parts")
      parts&.each&.with_index do |part, j|
        if part["text"]
          target = candidate["content"]["parts"][j]
          part["text"] << target["text"]
          @io << target["text"] if @io.respond_to?(:<<)
        end
      end
    end
  end
end
