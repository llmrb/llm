# frozen_string_literal: true

module LLM::OpenAI::ResponseParser
  ##
  # @private
  class RespondParser
    def initialize(body)
      @body = OpenStruct.from_hash(body)
    end

    def format(response)
      {
        id:,
        model:,
        input_tokens:,
        output_tokens:,
        total_tokens:,
        outputs: format_outputs(response)
      }
    end

    private

    def format_outputs(response)
      output.filter_map.with_index do |output, index|
        next unless output.content
        extra = {
          index:, response:,
          contents: output.content,
          annotations: output.annotations,
        }
        LLM::Message.new(output.role, format_text(output), extra)
      end
    end

    def format_text(output)
      output["content"]
        .select { _1["type"] == "output_text" }
        .map { _1["text"] }
        .join("\n")
    end

    def body = @body
    def id = body.id
    def model = body.model
    def input_tokens = body.usage.input_tokens
    def output_tokens = body.usage.output_tokens
    def total_tokens = body.usage.total_tokens
    def output = body.output
  end
end
