# frozen_string_literal: true

module LLM::OpenAI::ResponseParser
  ##
  # @private
  class CompletionParser
    def initialize(body)
      @body = LLM::Object.from_hash(body)
    end

    def format(response)
      {
        model:,
        prompt_tokens:,
        completion_tokens:,
        total_tokens:,
        choices: format_choices(response)
      }
    end

    private

    def format_choices(response)
      choices.map.with_index do |choice, index|
        message = choice.message
        extra = {
          index:, response:,
          logprobs: choice.logprobs,
          tool_calls: format_tool_calls(message.tool_calls),
          original_tool_calls: message.tool_calls
        }
        LLM::Message.new(message.role, message.content, extra)
      end
    end

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

    def body = @body
    def model = body.model
    def prompt_tokens = body.usage.prompt_tokens
    def completion_tokens = body.usage.completion_tokens
    def total_tokens = body.usage.total_tokens
    def choices = body.choices
  end
end
