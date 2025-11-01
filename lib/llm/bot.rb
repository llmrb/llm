# frozen_string_literal: true

module LLM
  ##
  # {LLM::Bot LLM::Bot} provides an object that can maintain a
  # conversation. A conversation can use the chat completions API
  # that all LLM providers support or the responses API that currently
  # only OpenAI supports.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm  = LLM.openai(key: ENV["KEY"])
  #   bot  = LLM::Bot.new(llm)
  #   url  = "https://en.wikipedia.org/wiki/Special:FilePath/Cognac_glass.jpg"
  #
  #   bot.chat "Your task is to answer all user queries", role: :system
  #   bot.chat ["Tell me about this URL", URI(url)], role: :user
  #   bot.chat ["Tell me about this PDF", File.open("handbook.pdf", "rb")], role: :user
  #   bot.chat "Are the URL and PDF similar to each other?", role: :user
  #
  #   # The full conversation history is in bot.messages
  #   bot.messages.each { print "[#{_1.role}] ", _1.content, "\n" }
  class Bot
    ##
    # Returns an Enumerable for the messages in a conversation
    # @return [LLM::Buffer<LLM::Message>]
    attr_reader :messages

    ##
    # @param [LLM::Provider] provider
    #  A provider
    # @param [Hash] params
    #  The parameters to maintain throughout the conversation.
    #  Any parameter the provider supports can be included and
    #  not only those listed here.
    # @option params [String] :model Defaults to the provider's default model
    # @option params [Array<LLM::Function>, nil] :tools Defaults to nil
    def initialize(provider, params = {})
      @provider = provider
      @params = {model: provider.default_model, schema: nil}.compact.merge!(params)
      @messages = LLM::Buffer.new(provider)
    end

    ##
    # Maintain a conversation via the chat completions API.
    # This method immediately sends a request to the LLM and returns the response.
    #
    # @param prompt (see LLM::Provider#complete)
    # @param params The params, including optional :role (defaults to :user), :stream, :tools, :schema etc.
    # @return [LLM::Response] Returns the LLM's response for this turn.
    # @example
    #   llm = LLM.openai(key: ENV["KEY"])
    #   bot = LLM::Bot.new(llm)
    #   response = bot.chat("Hello, what is your name?")
    #   puts response.choices[0].content
    def chat(prompt, params = {})
      prompt, params, messages = fetch(prompt, params)
      params = params.merge(messages: [@messages, *messages])
      params = @params.merge(params)
      res = @provider.complete(prompt, params)
      @messages.concat [LLM::Message.new(params[:role] || :user, prompt)]
      @messages.concat messages
      @messages.concat [res.choices[-1]]
      res
    end

    ##
    # Maintain a conversation via the responses API.
    # This method immediately sends a request to the LLM and returns the response.
    #
    # @note Not all LLM providers support this API
    # @param prompt (see LLM::Provider#complete)
    # @param params The params, including optional :role (defaults to :user), :stream, :tools, :schema etc.
    # @return [LLM::Response] Returns the LLM's response for this turn.
    # @example
    #   llm = LLM.openai(key: ENV["KEY"])
    #   bot = LLM::Bot.new(llm)
    #   res = bot.respond("What is the capital of France?")
    #   puts res.output_text
    def respond(prompt, params = {})
      prompt, params, messages = fetch(prompt, params)
      res_id = @messages.find(&:assistant?)&.response.id
      params = params.merge(previous_response_id: res_id)
      params = @params.merge(params)
      res = @provider.responses.create(prompt, params)
      @messages.concat [LLM::Message.new(params[:role] || :user, prompt)]
      @messages.concat messages
      @messages.concat [res.choices[-1]]
      res
    end

    ##
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "@provider=#{@provider.class}, @params=#{@params.inspect}, " \
      "@messages=#{@messages.inspect}>"
    end

    ##
    # Returns an array of functions that can be called
    # @return [Array<LLM::Function>]
    def functions
      @messages
        .select(&:assistant?)
        .flat_map(&:functions)
        .select(&:pending?)
    end

    ##
    # Returns token usage for the conversation
    # @note
    # This method returns token usage for the latest
    # assistant message, and it returns an empty object
    # if there are no assistant messages
    # @return [LLM::Object]
    def usage
      @messages.find(&:assistant?)&.usage || LLM::Object.from_hash({})
    end

    private

    def fetch(prompt, params)
      return [prompt, params, []] unless LLM::Builder === prompt
      messages = prompt.to_a
      prompt = messages.unshift
      params.merge!(role: prompt.role)
      [prompt, params, messages]
    end
  end
end
