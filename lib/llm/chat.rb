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
  #   bot.chat("Your task is to answer all of my questions", :system)
  #   bot.chat("Your answers should be short and concise", :system)
  #   bot.chat("What is 5 + 7 ?", :user)
  #   bot.chat("Why is the sky blue ?", :user)
  #   bot.chat("Why did the chicken cross the road ?", :user)
  #   bot.messages.map { print "[#{_1.role}]", _1.content, "\n" }
  class Chat
    ##
    # @return [Array<LLM::Message>]
    attr_reader :messages

    ##
    # @param [LLM::Provider] provider
    #  A provider
    # @param [String] model
    #  The model to maintain throughout the conversation
    # @param [Hash] params
    #  Other parameters to maintain throughout the conversation
    def initialize(provider, model: provider.default_model, **params)
      @provider = provider
      @params = params.merge!(model:)
      @lazy = false
      @messages = []
    end

    ##
    # Maintain a conversation via the chat completions API
    # @param prompt (see LLM::Provider#prompt)
    # @param role (see LLM::Provider#prompt)
    # @param params (see LLM::Provider#prompt)
    # @return [LLM::Chat]
    def chat(prompt, role = :user, **params)
      if lazy?
        @messages << [LLM::Message.new(role, prompt), @params.merge(params), :complete]
        self
      else
        completion = complete!(prompt, role, params)
        @messages.concat [Message.new(role, prompt), completion.choices[0]]
        self
      end
    end

    ##
    # Maintain a conversation via the responses API
    # @note Not all LLM providers support this API
    # @param prompt (see LLM::Provider#prompt)
    # @param role (see LLM::Provider#prompt)
    # @param params (see LLM::Provider#prompt)
    # @return [LLM::Chat]
    def respond(prompt, role = :user, **params)
      if lazy?
        @messages << [LLM::Message.new(role, prompt), @params.merge(params), :respond]
        self
      else
        @response = respond!(prompt, role, params)
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

    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "@provider=#{@provider.class}, @params=#{@params.inspect}, " \
      "@messages=#{@messages.inspect}, @lazy=#{@lazy.inspect}>"
    end

    private

    def respond!(prompt, role, params)
      @provider.responses.create(
        prompt,
        role,
        **@params.merge(params.merge(@response ? {previous_response_id: @response.id} : {}))
      )
    end

    def complete!(prompt, role, params)
      @provider.complete(
        prompt,
        role,
        **@params.merge(params.merge(messages:))
      )
    end
  end
end
