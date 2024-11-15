# frozen_string_literal: true

module LLM
  ##
  # {LLM::Conversation LLM::Conversation} provides a conversation
  # object that maintains a thread of messages that act as the
  # context of the conversation.
  #
  # @example
  #   llm = LLM.openai(key)
  #   bot = llm.chat("What is the capital of France?")
  #   bot.chat("What should we eat in Paris?")
  #   bot.chat("What is the weather like in Paris?")
  #   p bot.thread.map { [_1.role, _1.content] }
  class Conversation
    attr_reader :thread

    ##
    # @param [LLM::Provider] provider
    #  A provider
    def initialize(provider)
      @provider = provider
      @thread = []
    end

    ##
    # @param prompt (see LLM::Provider#prompt)
    # @return [LLM::Conversation]
    def chat(prompt, role = :user, **params)
      tap do
        prompt = transform_prompt(prompt)
        completion = @provider.complete(Message.new(role, prompt), **params)
        @thread.concat [Message.new(role.to_s, prompt), completion.choices.first]
      end
    end

    private

    def transform_prompt(...)
      @provider.transform_prompt(...)
    end
  end
end
