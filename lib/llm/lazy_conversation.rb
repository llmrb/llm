# frozen_string_literal: true

module LLM
  require_relative "message_queue"

  ##
  # {LLM::LazyConversation LLM::LazyConversation} provides a
  # conversation object that allows input prompts to be queued
  # and only sent to the LLM when a response is needed.
  #
  # @example
  #   llm = LLM.openai(key)
  #   bot = llm.chat("Be a helpful weather assistant", :system)
  #   bot.chat("What's the weather like in Rio?")
  #   bot.chat("What's the weather like in Algiers?")
  #   bot.messages.each do |message|
  #     # A single request is made at this point
  #   end
  class LazyConversation
    ##
    # @return [LLM::MessageQueue]
    attr_reader :messages

    ##
    # @param [LLM::Provider] provider
    #  A provider
    def initialize(provider, params = {})
      @provider = provider
      @params = params
      @messages = LLM::MessageQueue.new(provider)
    end

    ##
    # @param prompt (see LLM::Provider#prompt)
    # @return [LLM::Conversation]
    def chat(prompt, role = :user, **params)
      tap { @messages << [prompt, role, @params.merge(params)] }
    end

    ##
    # @param [#to_s] role
    #  The role of the last message.
    #  Defaults to the LLM's assistant role (eg "assistant" or "model")
    # @return [LLM::Message]
    #  The last message for the given role
    def last_message(role: @provider.assistant_role)
      messages.reverse_each.find { _1.role == role.to_s }
    end
    alias_method :recent_message, :last_message
  end
end
