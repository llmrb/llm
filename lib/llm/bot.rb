# frozen_string_literal: true

module LLM
  ##
  # {LLM::Bot LLM::Bot} provides a bot object that can maintain a
  # a conversation. A conversation can use the chat completions API
  # that all LLM providers support or the responses API that a select
  # few LLM providers support.
  #
  # @example example #1
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm  = LLM.openai(ENV["KEY"])
  #   bot  = LLM::Bot.new(llm)
  #   msgs = bot.chat do |prompt|
  #     prompt.system "Answer the following questions."
  #     prompt.user "What is 5 + 7 ?"
  #     prompt.user "Why is the sky blue ?"
  #     prompt.user "Why did the chicken cross the road ?"
  #   end
  #   msgs.each { print "[#{_1.role}]", _1.content, "\n" }
  #
  # @example example #2
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   bot = LLM::Bot.new(llm)
  #   bot.chat "Answer the following questions.", role: :system
  #   bot.chat "What is 5 + 7 ?", role: :user
  #   bot.chat "Why is the sky blue ?", role: :user
  #   bot.chat "Why did the chicken cross the road ?", role: :user
  #   bot.messages.each { print "[#{_1.role}]", _1.content, "\n" }
  class Bot
    require_relative "bot/prompt/completion"
    require_relative "bot/prompt/respond"
    require_relative "bot/conversable"
    require_relative "bot/builder"

    include Conversable
    include Builder

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
    # @option params [#to_json, nil] :schema Defaults to nil
    # @option params [Array<LLM::Function>, nil] :tools Defaults to nil
    def initialize(provider, params = {})
      @provider = provider
      @params = {model: provider.default_model, schema: nil}.compact.merge!(params)
      @messages = LLM::Buffer.new(provider)
    end

    ##
    # Maintain a conversation via the chat completions API
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @yieldparam [LLM::Bot::CompletionPrompt] prompt Yields a prompt
    # @return [LLM::Bot, Array<LLM::Message>, LLM::Buffer]
    #  Returns self unless given a block, otherwise returns messages
    def chat(prompt = nil, params = {})
      if block_given?
        params = prompt
        yield Prompt::Completion.new(self, params)
        messages
      elsif prompt.nil?
        raise ArgumentError, "wrong number of arguments (given 0, expected 1)"
      else
        params = {role: :user}.merge!(params)
        tap { async_completion(prompt, params) }
      end
    end

    ##
    # Maintain a conversation via the responses API
    # @note Not all LLM providers support this API
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @return [LLM::Bot, Array<LLM::Message>, LLM::Buffer]
    #  Returns self unless given a block, otherwise returns messages
    def respond(prompt = nil, params = {})
      if block_given?
        params = prompt
        yield Prompt::Respond.new(self, params)
        messages
      elsif prompt.nil?
        raise ArgumentError, "wrong number of arguments (given 0, expected 1)"
      else
        params = {role: :user}.merge!(params)
        tap { async_response(prompt, params) }
      end
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
      messages
        .select(&:assistant?)
        .flat_map(&:functions)
        .select(&:pending?)
    end
  end
end
