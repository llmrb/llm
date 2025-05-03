# frozen_string_literal: true

module LLM::Gemini::ResponseParser
  class CompletionParser
    def initialize(body)
      @body = OpenStruct.from_hash(body)
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
      candidates.map.with_index do |choice, index|
        content = choice.content
        role, parts = content.role, content.parts
        text  = parts.filter_map { _1["text"] }.join
        tools = parts.filter_map { _1["functionCall"] }
        extra = {index:, response:, tool_calls: format_tool_calls(tools), original_tool_calls: tools}
        LLM::Message.new(role, text, extra)
      end
    end

    def format_tool_calls(tools)
      (tools || []).map do |tool|
        function = {name: tool.name, arguments: tool.args}
        OpenStruct.new(function)
      end
    end

    def body = @body
    def model = body.modelVersion
    def prompt_tokens = body.usageMetadata.promptTokenCount
    def completion_tokens = body.usageMetadata.candidatesTokenCount
    def total_tokens = body.usageMetadata.totalTokenCount
    def candidates = body.candidates
  end
end
