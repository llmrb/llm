# frozen_string_literal: true

module LLM
  ##
  # The Anthropic class implements a provider for
  # [Anthropic](https://www.anthropic.com)
  class Anthropic < Provider
    require_relative "anthropic/format"
    require_relative "anthropic/error_handler"
    require_relative "anthropic/stream_parser"
    require_relative "anthropic/response_parser"
    require_relative "anthropic/models"
    include Format

    HOST = "api.anthropic.com"

    ##
    # @param key (see LLM::Provider#initialize)
    def initialize(**)
      super(host: HOST, **)
    end

    ##
    # Provides an embedding via VoyageAI per
    # [Anthropic's recommendation](https://docs.anthropic.com/en/docs/build-with-claude/embeddings)
    # @param input (see LLM::Provider#embed)
    # @param [String] key
    #  Valid key for the VoyageAI API
    # @param [String] model
    #  The embedding model to use
    # @param [Hash] params
    #  Other embedding parameters
    # @raise (see LLM::Provider#request)
    # @return (see LLM::Provider#embed)
    def embed(input, key:, model: "voyage-2", **params)
      llm = LLM.voyageai(key:)
      llm.embed(input, **params.merge(model:))
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://docs.anthropic.com/en/api/messages Anthropic docs
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::Provider#request)
    # @raise [LLM::Error::PromptError]
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
      Response::Completion.new(res).extend(response_parser)
    end

    ##
    # Provides an interface to Anthropic's models API
    # @see https://docs.anthropic.com/en/api/models-list
    # @return [LLM::Anthropic::Models]
    def models
      LLM::Anthropic::Models.new(self)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "assistant"
    end

    ##
    # Returns the default model for chat completions
    # @see https://docs.anthropic.com/en/docs/about-claude/models/all-models#model-comparison-table claude-3-5-sonnet-20240620
    # @return [String]
    def default_model
      "claude-3-5-sonnet-20240620"
    end

    private

    def headers
      (@headers || {}).merge(
        "Content-Type" => "application/json",
        "x-api-key" => @key,
        "anthropic-version" => "2023-06-01"
      )
    end

    def response_parser
      LLM::Anthropic::ResponseParser
    end

    def stream_parser
      LLM::Anthropic::StreamParser
    end

    def error_handler
      LLM::Anthropic::ErrorHandler
    end
  end
end
