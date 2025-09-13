# frozen_string_literal: true

module LLM::OpenAI::Response
  module Completion
    def choices
      body.choices.map.with_index do |choice, index|
        choice = LLM::Object.from_hash(choice)
        message = choice.message
        extra = {
          index:, response: self,
          logprobs: choice.logprobs,
          tool_calls: format_tool_calls(message.tool_calls),
          original_tool_calls: message.tool_calls
        }
        LLM::Message.new(message.role, message.content, extra)
      end
    end
    alias_method :messages, :choices

    def model = body.model
    def prompt_tokens = body.usage["prompt_tokens"]
    def completion_tokens = body.usage["completion_tokens"]
    def total_tokens = body.usage["total_tokens"]

    private

    def format_tool_calls(tools)
      (tools || []).filter_map do |tool|
        next unless tool.function
        tool = {
          id: tool.id,
          name: tool.function.name,
          arguments: JSON.parse(tool.function.arguments)
        }
        LLM::Object.new(tool)
      end
    end
  end
end
