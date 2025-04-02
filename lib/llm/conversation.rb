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
    def initialize(provider, params = {})
      @provider = provider
      @params = params
      @messages = []
    end

    ##
    # @param prompt (see LLM::Provider#prompt)
    # @return [LLM::Conversation]
    def chat(prompt, role = :user, **params)
      tap do
        completion = @provider.complete(prompt, role, **@params.merge(params.merge(messages:)))
        @messages.concat [Message.new(role, prompt), completion.choices[0]]
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
  end
end
