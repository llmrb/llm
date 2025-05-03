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
        outputs: [format_message(response)]
      }
    end

    private

    def format_message(response)
      message = LLM::Message.new("assistant", +"", {response:, tool_calls: []})
      choices.each.with_index do |choice, index|
        if choice.type == "function_call"
          message.extra[:tool_calls] << format_tool(choice)
        elsif choice.content
          choice.content.each do |c|
            next unless c["type"] == "output_text"
            message.content << c["text"] << "\n"
          end
        end
      end
      message
    end

    def format_tool(tool)
      OpenStruct.new(
        id: tool.call_id,
        name: tool.name,
        arguments: JSON.parse(tool.arguments)
      )
    end

    def body = @body
    def id = body.id
    def model = body.model
    def input_tokens = body.usage.input_tokens
    def output_tokens = body.usage.output_tokens
    def total_tokens = body.usage.total_tokens
    def choices = body.output
    def tools = output.select { _1.type == "function_call" }
  end
end
