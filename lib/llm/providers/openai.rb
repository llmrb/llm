# frozen_string_literal: true

module LLM
  ##
  # The OpenAI class implements a provider for
  # [OpenAI](https://platform.openai.com/)
  class OpenAI < Provider
    HOST = "api.openai.com"
    PATH = "/v1"

    DEFAULT_PARAMS = {
      model: "gpt-4o-mini"
    }.freeze

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret)
      super(secret, HOST)
    end

    def complete(prompt, thread: [], **params)
      req = Net::HTTP::Post.new [PATH, "chat", "completions"].join("/")
      body = {
        messages: thread.map(&:to_h).push({role: "user", content: prompt}),
        **DEFAULT_PARAMS,
        **params
      }

      req.content_type = "application/json"
      req.body = JSON.generate(body)
      auth req
      res = request @http, req

      Response::Completion.new(res.body, self).tap { _1.thread = thread }
    end

    def chat(prompt, params = {})
      completion = complete(prompt, **params)
      Conversation.new(completion, self)
    end

    private

    ##
    # @param (see LLM::Provider#completion_model)
    # @return (see LLM::Provider#completion_model)
    def completion_model(_completion, raw)
      raw["model"]
    end

    ##
    # @param (see LLM::Provider#completion_messages)
    # @return (see LLM::Provider#completion_messages)
    def completion_messages(completion, raw)
      raw["choices"].map do
        LLM::Message.new(*_1["message"].values_at("role", "content"))
      end.prepend(*completion.thread)
    end

    def auth(req)
      req["Authorization"] = "Bearer #{@secret}"
    end
  end
end
