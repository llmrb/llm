# frozen_string_literal: true

module LLM
  ##
  # {LLM::Conversation LLM::Conversation} provides a conversation
  # object that maintains a thread of messages that acts as context
  # throughout the conversation.
  # @example
  #   llm = LLM.openai(ENV["KEY"])
  #   convo = llm.chat("You are my climate expert", :system)
  #   convo.chat("What's the climate like in Rio de Janerio?", :user)
  #   convo.chat("What's the climate like in Algiers?", :user)
  #   convo.chat("What's the climate like in Tokyo?", :user)
  #   p bot.messages.map { [_1.role, _1.content] }
  class Conversation
    ##
    # @return [Array<LLM::Message>]
    attr_reader :messages

    ##
    # @param [LLM::Provider] provider
    #  A provider
    # @param [Hash] params
    #  The parameters to maintain throughout the conversation
    def initialize(provider, params = {})
      @provider = provider
      @params = params
      @lazy = false
      @messages = []
    end

    ##
    # @param prompt (see LLM::Provider#prompt)
    # @return [LLM::Conversation]
    def chat(prompt, role = :user, **params)
      tap do
        if lazy?
          @messages << [LLM::Message.new(role, prompt), @params.merge(params)]
        else
          completion = complete(prompt, role, params)
          @messages.concat [Message.new(role, prompt), completion.choices[0]]
        end
      end
    end

    ##
    # @note
    #  The `read_response` and `recent_message` methods are aliases of
    #  the `last_message` method, and you can choose the name that best
    #  fits your context or code style.
    # @param [#to_s] role
    #  The role of the last message.
    #  Defaults to the LLM's assistant role (eg "assistant" or "model")
    # @return [LLM::Message]
    #  The last message for the given role
    def last_message(role: @provider.assistant_role)
      messages.reverse_each.find { _1.role == role.to_s }
    end
    alias_method :recent_message, :last_message
    alias_method :read_response, :last_message

    ##
    # Enables lazy mode for the conversation.
    # @return [LLM::Conversation]
    def lazy
      tap do
        next if lazy?
        @lazy = true
        @messages = LLM::MessageQueue.new(@provider)
      end
    end

    ##
    # @return [Boolean]
    #  Returns true if the conversation is lazy
    def lazy?
      @lazy
    end

    private

    def complete(prompt, role, params)
      @provider.complete(
        prompt,
          role,
          **@params.merge(params.merge(messages:))
      )
    end
  end
end
