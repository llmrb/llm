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
      @body = LLM::Object.from_hash({candidates: []})
      @io = io
    end

    ##
    # @param [Hash] chunk
    # @return [LLM::Gemini::StreamParser]
    def parse!(chunk)
      tap { merge_chunk!(LLM::Object.from_hash(chunk)) }
    end

    private

    def merge_chunk!(chunk)
      chunk.each do |key, value|
        if key.to_s == "candidates"
          merge_candidates!(value)
        elsif key.to_s == "usageMetadata" &&
            @body.usageMetadata.is_a?(LLM::Object) &&
            value.is_a?(LLM::Object)
          @body.usageMetadata = LLM::Object.from_hash(@body.usageMetadata.to_h.merge(value.to_h))
        else
          @body[key] = value
        end
      end
    end

    def merge_candidates!(deltas)
      deltas.each do |delta|
        index = delta.index
        @body.candidates[index] ||= LLM::Object.from_hash({content: {parts: []}})
        candidate = @body.candidates[index]
        delta.each do |key, value|
          if key.to_s == "content"
            merge_candidate_content!(candidate.content, value) if value
          else
            candidate[key] = value # Overwrite other fields
          end
        end
      end
    end

    def merge_candidate_content!(content, delta)
      delta.each do |key, value|
        if key.to_s == "parts"
          content.parts ||= []
          merge_content_parts!(content.parts, value) if value
        else
          content[key] = value
        end
      end
    end

    def merge_content_parts!(parts, deltas)
      deltas.each do |delta|
        if delta.text
          merge_text!(parts, delta)
        elsif delta.functionCall
          merge_function_call!(parts, delta)
        elsif delta.inlineData
          parts << delta
        elsif delta.functionResponse
          parts << delta
        elsif delta.fileData
          parts << delta
        end
      end
    end

    def merge_text!(parts, delta)
      last_existing_part = parts.last
      if last_existing_part&.text
        last_existing_part.text << delta.text
        @io << delta.text if @io.respond_to?(:<<)
      else
        parts << delta
        @io << delta.text if @io.respond_to?(:<<)
      end
    end

    def merge_function_call!(parts, delta)
      last_existing_part = parts.last
      if last_existing_part && last_existing_part.functionCall
        last_existing_part.functionCall = LLM::Object.from_hash(
          last_existing_part.functionCall.to_h.merge(delta.functionCall.to_h)
        )
      else
        parts << delta
      end
    end
  end
end
