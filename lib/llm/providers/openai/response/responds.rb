# frozen_string_literal: true

module LLM::OpenAI::Response
  module Responds
    def response_id = respond_to?(:response) ? response["id"] : id
    def outputs = [format_message]
    def choices = body.output
    def tools = output.select { _1.type == "function_call" }

    private

    def format_message
      message = LLM::Message.new("assistant", +"", {response: self, tool_calls: []})
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
      LLM::Object.new(
        id: tool.call_id,
        name: tool.name,
        arguments: JSON.parse(tool.arguments)
      )
    end
  end
end
