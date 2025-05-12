# frozen_string_literal: true

module LLM::Ollama::ResponseParser
  ##
  # @private
  class CompletionParser
    def initialize(body)
      @body = LLM::Object.from_hash(body)
    end

    def format(response)
      {
        model:,
        choices: [format_choices(response)],
        prompt_tokens:,
        completion_tokens:
      }
    end

    private

    def format_choices(response)
      role, content, calls = message.to_h.values_at(:role, :content, :tool_calls)
      extra = {response:, tool_calls: format_tool_calls(calls)}
      LLM::Message.new(role, content, extra)
    end

    def format_tool_calls(tools)
      return [] unless tools
      tools.filter_map do |tool|
        next unless tool["function"]
        LLM::Object.new(tool["function"])
      end
    end

    def body = @body
    def model = body.model
    def prompt_tokens = body.prompt_eval_count
    def completion_tokens = body.eval_count
    def message = body.message
  end
end
