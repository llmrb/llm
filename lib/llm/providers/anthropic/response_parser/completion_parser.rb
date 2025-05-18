# frozen_string_literal: true

module LLM::Anthropic::ResponseParser
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
      texts.map.with_index do |choice, index|
        extra = {index:, response:, tool_calls: format_tool_calls(tools), original_tool_calls: tools}
        LLM::Message.new(role, choice.text, extra)
      end
    end

    def format_tool_calls(tools)
      (tools || []).filter_map do |tool|
        tool = {
          id: tool.id,
          name: tool.name,
          arguments: tool.input
        }
        LLM::Object.new(tool)
      end
    end

    def body = @body
    def role = body.role
    def model = body.model
    def prompt_tokens = body.usage&.input_tokens
    def completion_tokens = body.usage&.output_tokens
    def total_tokens = body.usage&.total_tokens
    def parts = body.content
    def texts = parts.select { _1["type"] == "text" }
    def tools = parts.select { _1["type"] == "tool_use" }
  end
end
