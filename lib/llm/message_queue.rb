# frozen_string_literal: true

module LLM
  ##
  # {LLM::MessageQueue LLM::MessageQueue} provides an Enumerable
  # object that yields each message in a conversation on-demand,
  # and only sends a request to the LLM when a response is needed.
  class MessageQueue
    include Enumerable

    ##
    # @param [LLM::Provider] provider
    # @return [LLM::MessageQueue]
    def initialize(provider)
      @provider = provider
      @pending = []
      @completed = []
    end

    ##
    # @yield [LLM::Message]
    #  Yields each message in the conversation thread
    # @raise (see LLM::Provider#complete)
    # @return [void]
    def each
      complete! unless @pending.empty?
      @completed.each { yield(_1) }
    end

    ##
    # @param [[LLM::Message, Hash]] item
    #  A message and its parameters
    # @return [void]
    def <<(item)
      @pending << item
      self
    end
    alias_method :push, :<<

    private

    def complete!
      message, params = @pending[-1]
      messages = @pending[0..-2].map { _1[0] }
      completion = @provider.complete(
        message.content,
        message.role,
        **params.merge(messages:)
      )
      @completed.concat([*messages, message, completion.choices[0]])
      @pending.clear
    end
  end
end
