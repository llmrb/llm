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
        if @body.candidates[i]
          parts = @body.candidates[i].dig("content", "parts")
          parts&.each&.with_index do |part, j|
            if part["text"]
              target = candidate["content"]["parts"][j]
              part["text"] << target["text"]
              @io << part["text"] if @io.respond_to?(:<<)
            end
          end
        else
          @body.candidates[i] = candidate
        end
      end
    end
  end
end
