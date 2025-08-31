# frozen_string_literal: true

module LLM
  ##
  # The OpenAI class implements a provider for
  # [OpenAI](https://platform.openai.com/).
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(key: ENV["KEY"])
  #   bot = LLM::Bot.new(llm)
  #   bot.chat ["Tell me about this photo", File.open("/images/capybara.jpg", "rb")]
  #   bot.messages.select(&:assistant?).each { print "[#{_1.role}]", _1.content, "\n" }
  class OpenAI < Provider
    require_relative "openai/response/embedding"
    require_relative "openai/response/completion"
    require_relative "openai/error_handler"
    require_relative "openai/format"
    require_relative "openai/stream_parser"
    require_relative "openai/models"
    require_relative "openai/responses"
    require_relative "openai/images"
    require_relative "openai/audio"
    require_relative "openai/files"
    require_relative "openai/moderations"
    require_relative "openai/vector_stores"

    include Format

    HOST = "api.openai.com"

    ##
    # @param key (see LLM::Provider#initialize)
    def initialize(**)
      super(host: HOST, **)
    end

    ##
    # Provides an embedding
    # @see https://platform.openai.com/docs/api-reference/embeddings/create OpenAI docs
    # @param input (see LLM::Provider#embed)
    # @param model (see LLM::Provider#embed)
    # @param params (see LLM::Provider#embed)
    # @raise (see LLM::Provider#request)
    # @return (see LLM::Provider#embed)
    def embed(input, model: "text-embedding-3-small", **params)
      req = Net::HTTP::Post.new("/v1/embeddings", headers)
      req.body = JSON.dump({input:, model:}.merge!(params))
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::OpenAI::Response::Embedding)
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://platform.openai.com/docs/api-reference/chat/create OpenAI docs
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::Provider#request)
    # @raise [LLM::PromptError]
    #  When given an object a provider does not understand
    # @return (see LLM::Provider#complete)
    def complete(prompt, params = {})
      params = {role: :user, model: default_model}.merge!(params)
      params = [params, format_schema(params), format_tools(params)].inject({}, &:merge!).compact
      role, stream = params.delete(:role), params.delete(:stream)
      params[:stream] = true if stream.respond_to?(:<<) || stream == true
      req = Net::HTTP::Post.new("/v1/chat/completions", headers)
      messages = [*(params.delete(:messages) || []), Message.new(role, prompt)]
      body = JSON.dump({messages: format(messages, :complete).flatten}.merge!(params))
      set_body_stream(req, StringIO.new(body))
      res = execute(request: req, stream:)
      LLM::Response.new(res).extend(LLM::OpenAI::Response::Completion)
    end

    ##
    # Provides an interface to OpenAI's response API
    # @see https://platform.openai.com/docs/api-reference/responses/create OpenAI docs
    # @return [LLM::OpenAI::Responses]
    def responses
      LLM::OpenAI::Responses.new(self)
    end

    ##
    # Provides an interface to OpenAI's image generation API
    # @see https://platform.openai.com/docs/api-reference/images/create OpenAI docs
    # @return [LLM::OpenAI::Images]
    def images
      LLM::OpenAI::Images.new(self)
    end

    ##
    # Provides an interface to OpenAI's audio generation API
    # @see https://platform.openai.com/docs/api-reference/audio/createSpeech OpenAI docs
    # @return [LLM::OpenAI::Audio]
    def audio
      LLM::OpenAI::Audio.new(self)
    end

    ##
    # Provides an interface to OpenAI's files API
    # @see https://platform.openai.com/docs/api-reference/files/create OpenAI docs
    # @return [LLM::OpenAI::Files]
    def files
      LLM::OpenAI::Files.new(self)
    end

    ##
    # Provides an interface to OpenAI's models API
    # @see https://platform.openai.com/docs/api-reference/models/list OpenAI docs
    # @return [LLM::OpenAI::Models]
    def models
      LLM::OpenAI::Models.new(self)
    end

    ##
    # Provides an interface to OpenAI's moderation API
    # @see https://platform.openai.com/docs/api-reference/moderations/create OpenAI docs
    # @see https://platform.openai.com/docs/models#moderation OpenAI moderation models
    # @return [LLM::OpenAI::Moderations]
    def moderations
      LLM::OpenAI::Moderations.new(self)
    end

    ##
    # Provides an interface to OpenAI's vector store API
    # @see https://platform.openai.com/docs/api-reference/vector-stores/create OpenAI docs
    # @return [LLM::OpenAI::VectorStore]
    def vector_stores
      LLM::OpenAI::VectorStores.new(self)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "assistant"
    end

    ##
    # Returns the default model for chat completions
    # @see https://platform.openai.com/docs/models/gpt-4.1 gpt-4.1
    # @return [String]
    def default_model
      "gpt-4.1"
    end

    ##
    # @note
    #  This method includes certain tools that require configuration
    #  through a set of options that are easier to set through the
    #  {LLM::Provider#tool LLM::Provider#tool} method.
    # @return (see LLM::Provider#tools)
    def tools
      {
        web_search: tool(:web_search),
        file_search: tool(:file_search),
        image_generation: tool(:image_generation),
        code_interpreter: tool(:code_interpreter),
        computer_use: tool(:computer_use)
      }
    end

    ##
    # A convenience method for performing a web search using the
    # Web Search tool.
    # @param query [String] The search query.
    # @return [LLM::Response] The response from the LLM provider.
    def web_search(query:)
      responses.create(query, store: false, tools: [tools[:web_search]])
    end

    private

    def headers
      (@headers || {}).merge(
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@key}"
      )
    end

    def stream_parser
      LLM::OpenAI::StreamParser
    end

    def error_handler
      LLM::OpenAI::ErrorHandler
    end
  end
end
