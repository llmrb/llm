# frozen_string_literal: true

module LLM::OpenAI::Response
  module Responds
    def model = body.model
    def response_id = respond_to?(:response) ? response["id"] : id
    def choices = [format_message]
    def annotations = choices[0].annotations

    def prompt_tokens = body.usage&.input_tokens
    def completion_tokens = body.usage&.output_tokens
    def total_tokens = body.usage&.total_tokens

    ##
    # Returns the aggregated text content from the response outputs.
    # @return [String]
    def output_text
      choices.find(&:assistant?).content || ""
    end

    private

    def format_message
      message = LLM::Message.new("assistant", +"", {response: self, tool_calls: []})
      output.each.with_index do |choice, index|
        if choice.type == "function_call"
          message.extra[:tool_calls] << format_tool(choice)
        elsif choice.content
          choice.content.each do |c|
            next unless c["type"] == "output_text"
            message.content << c["text"] << "\n"
            next unless c["annotations"]
            message.extra["annotations"] = [*message.extra["annotations"], *c["annotations"]]
          end
        end
      end
      message
    end

    def format_tool(tool)
      LLM::Object.new(
        id: tool.call_id,
        name: tool.name,
        arguments: JSON.parse(tool.arguments)
      )
    end
  end
end
