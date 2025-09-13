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
  #   msgs = bot.chat do |prompt|
  #     prompt.system "Your task is to answer all user queries"
  #     prompt.user ["Tell me about this URL", URI(url)]
  #     prompt.user ["Tell me about this PDF", File.open("handbook.pdf", "rb")]
  #     prompt.user "Are the URL and PDF similar to each other?"
  #   end
  #
  #   # At this point, we execute a single request
  #   msgs.each { print "[#{_1.role}] ", _1.content, "\n" }
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
    # @overload def chat(prompt, params = {})
    #   @param prompt (see LLM::Provider#complete)
    #   @param params The params
    #   @return [LLM::Bot]
    #     Returns self
    # @overload def chat(prompt, params, &block)
    #   @param prompt (see LLM::Provider#complete)
    #   @param params The params
    #   @yield prompt Yields a prompt
    #   @return [LLM::Buffer]
    #     Returns messages
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
    # @overload def respond(prompt, params = {})
    #   @param prompt (see LLM::Provider#complete)
    #   @param params The params
    #   @return [LLM::Bot]
    #     Returns self
    # @overload def respond(prompt, params, &block)
    #   @note Not all LLM providers support this API
    #   @param prompt (see LLM::Provider#complete)
    #   @param params The params
    #   @yield prompt Yields a prompt
    #   @return [LLM::Buffer]
    #     Returns messages
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

    ##
    # @example
    #   llm = LLM.openai(key: ENV["KEY"])
    #   bot = LLM::Bot.new(llm, stream: $stdout)
    #   bot.chat("Hello", role: :user).flush
    # Drains the buffer and returns all messages as an array
    # @return [Array<LLM::Message>]
    def drain
      messages.drain
    end
    alias_method :flush, :drain

    ##
    # Returns token usage for the conversation
    # @note
    # This method returns token usage for the latest
    # assistant message, and it returns an empty object
    # if there are no assistant messages
    # @return [LLM::Object]
    def usage
      messages.find(&:assistant?)&.usage || LLM::Object.from_hash({})
    end
  end
end
