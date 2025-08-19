# frozen_string_literal: true

module LLM
  ##
  # The Anthropic class implements a provider for
  # [Anthropic](https://www.anthropic.com).
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.anthropic(key: ENV["KEY"])
  #   bot = LLM::Bot.new(llm)
  #   bot.chat ["Tell me about this photo", File.open("/images/dog.jpg", "rb")]
  #   bot.messages.select(&:assistant?).each { print "[#{_1.role}]", _1.content, "\n" }
  class Anthropic < Provider
    require_relative "anthropic/response/completion"
    require_relative "anthropic/format"
    require_relative "anthropic/error_handler"
    require_relative "anthropic/stream_parser"
    require_relative "anthropic/files"
    require_relative "anthropic/models"
    include Format

    HOST = "api.anthropic.com"

    ##
    # @param key (see LLM::Provider#initialize)
    def initialize(**)
      super(host: HOST, **)
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://docs.anthropic.com/en/api/messages Anthropic docs
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::Provider#request)
    # @raise [LLM::PromptError]
    #  When given an object a provider does not understand
    # @return (see LLM::Provider#complete)
    def complete(prompt, params = {})
      params = {role: :user, model: default_model, max_tokens: 1024}.merge!(params)
      params = [params, format_tools(params)].inject({}, &:merge!).compact
      role, stream = params.delete(:role), params.delete(:stream)
      params[:stream] = true if stream.respond_to?(:<<) || stream == true
      req = Net::HTTP::Post.new("/v1/messages", headers)
      messages = [*(params.delete(:messages) || []), Message.new(role, prompt)]
      body = JSON.dump({messages: [format(messages)].flatten}.merge!(params))
      set_body_stream(req, StringIO.new(body))
      res = execute(request: req, stream:)
      LLM::Response.new(res).extend(LLM::Anthropic::Response::Completion)
    end

    ##
    # Provides an interface to Anthropic's models API
    # @see https://docs.anthropic.com/en/api/models-list
    # @return [LLM::Anthropic::Models]
    def models
      LLM::Anthropic::Models.new(self)
    end

    ##
    # Provides an interface to Anthropic's files API
    # @see https://docs.anthropic.com/en/docs/build-with-claude/files Anthropic docs
    # @return [LLM::Anthropic::Files]
    def files
      LLM::Anthropic::Files.new(self)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "assistant"
    end

    ##
    # Returns the default model for chat completions
    # @see https://docs.anthropic.com/en/docs/about-claude/models/all-models#model-comparison-table claude-sonnet-4-20250514
    # @return [String]
    def default_model
      "claude-sonnet-4-20250514"
    end

    private

    def headers
      (@headers || {}).merge(
        "Content-Type" => "application/json",
        "x-api-key" => @key,
        "anthropic-version" => "2023-06-01",
        "anthropic-beta" => "files-api-2025-04-14"
      )
    end

    def stream_parser
      LLM::Anthropic::StreamParser
    end

    def error_handler
      LLM::Anthropic::ErrorHandler
    end
  end
end
