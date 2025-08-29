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

    def merge_candidates!(new_candidates_list)
      new_candidates_list.each do |new_candidate_delta|
        index = new_candidate_delta.index
        @body.candidates[index] ||= LLM::Object.from_hash({content: {parts: []}})
        existing_candidate = @body.candidates[index]
        new_candidate_delta.each do |key, value|
          if key.to_s == "content"
            merge_candidate_content!(existing_candidate.content, value) if value
          else
            existing_candidate[key] = value # Overwrite other fields
          end
        end
      end
    end

    def merge_candidate_content!(existing_content, new_content_delta)
      new_content_delta.each do |key, value|
        if key.to_s == "parts"
          existing_content.parts ||= []
          merge_content_parts!(existing_content.parts, value) if value
        else
          existing_content[key] = value
        end
      end
    end

    def merge_content_parts!(existing_parts, new_parts_delta)
      new_parts_delta.each do |new_part_delta|
        if new_part_delta.text
          last_existing_part = existing_parts.last
          if last_existing_part&.text
            last_existing_part.text << new_part_delta.text
            @io << new_part_delta.text if @io.respond_to?(:<<)
          else
            existing_parts << new_part_delta
            @io << new_part_delta.text if @io.respond_to?(:<<)
          end
        elsif new_part_delta.functionCall
          existing_parts << new_part_delta
        end
      end
    end
  end
end
