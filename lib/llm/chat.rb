# frozen_string_literal: true

module LLM
  ##
  # {LLM::Chat LLM::Chat} provides a chat object that maintains a
  # thread of messages that acts as context throughout a conversation.
  # A conversation can use the chat completions API that most LLM providers
  # support or the responses API that a select few LLM providers support.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   bot = LLM::Chat.new(llm).lazy
  #   bot.chat("Provide short and concise answers", role: :system)
  #   bot.chat("What is 5 + 7 ?", role: :user)
  #   bot.chat("Why is the sky blue ?", role: :user)
  #   bot.chat("Why did the chicken cross the road ?", role: :user)
  #   bot.messages.map { print "[#{_1.role}]", _1.content, "\n" }
  class Chat
    ##
    # @return [Array<LLM::Message>]
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
      @lazy = false
      @messages = [].extend(Array)
    end

    ##
    # Maintain a conversation via the chat completions API
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def chat(prompt, params = {})
      params = {role: :user}.merge!(params)
      if lazy?
        role = params.delete(:role)
        @messages << [LLM::Message.new(role, prompt), @params.merge(params), :complete]
        self
      else
        role = params[:role]
        completion = complete!(prompt, params)
        @messages.concat [Message.new(role, prompt), completion.choices[0]]
        self
      end
    end

    ##
    # Maintain a conversation via the responses API
    # @note Not all LLM providers support this API
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def respond(prompt, params = {})
      params = {role: :user}.merge!(params)
      if lazy?
        role = params.delete(:role)
        @messages << [LLM::Message.new(role, prompt), @params.merge(params), :respond]
        self
      else
        role = params[:role]
        @response = respond!(prompt, params)
        @messages.concat [Message.new(role, prompt), @response.outputs[0]]
        self
      end
    end

    ##
    # The last message in the conversation.
    # @note
    #  The `read_response` and `recent_message` methods are aliases of
    #  the `last_message` method, and you can choose the name that best
    #  fits your context or code style.
    # @param [#to_s] role
    #  The role of the last message.
    # @return [LLM::Message]
    def last_message(role: @provider.assistant_role)
      messages.reverse_each.find { _1.role == role.to_s }
    end
    alias_method :recent_message, :last_message
    alias_method :read_response, :last_message

    ##
    # Enables lazy mode for the conversation.
    # @return [LLM::Chat]
    def lazy
      tap do
        next if lazy?
        @lazy = true
        @messages = LLM::Buffer.new(@provider)
      end
    end

    ##
    # @return [Boolean]
    #  Returns true if the conversation is lazy
    def lazy?
      @lazy
    end

    ##
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "@provider=#{@provider.class}, @params=#{@params.inspect}, " \
      "@messages=#{@messages.inspect}, @lazy=#{@lazy.inspect}>"
    end

    ##
    # Returns an array of functions that can be called
    # @return [Array<LLM::Function>]
    def functions
      messages
        .select(&:assistant?)
        .flat_map(&:functions)
        .reject { _1.called? || _1.cancelled? }
    end

    private

    ##
    # @private
    module Array
      def find(...)
        reverse_each.find(...)
      end

      def unread
        reject(&:read?)
      end
    end
    private_constant :Array

    def respond!(prompt, params)
      @provider.responses.create(
        prompt,
        @params.merge(params.merge(@response ? {previous_response_id: @response.id} : {}))
      )
    end

    def complete!(prompt, params)
      @provider.complete(
        prompt,
        @params.merge(params.merge(messages:))
      )
    end
  end
end
