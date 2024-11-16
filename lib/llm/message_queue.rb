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
      @messages = []
    end

    ##
    # @yield [LLM::Message]
    #  Yields each message in the conversation thread
    # @raise (see LLM::Provider#complete)
    # @return [void]
    def each
      @messages = complete! unless @messages.grep(LLM::Message).size == @messages.size
      @messages.each { yield(_1) }
    end

    ##
    # @param message [Object]
    #  A message to add to the conversation thread
    # @return [void]
    def <<(message)
      @messages << message
    end
    alias_method :push, :<<

    private

    def complete!
      prompt, role, params = @messages[-1]
      rest = @messages[0..-2].map { (Array === _1) ? LLM::Message.new(_1[1], _1[0]) : _1 }
      comp = @provider.complete(prompt, role, **params.merge(messages: rest)).choices.last
      [*rest, LLM::Message.new(role, prompt), comp]
    end
  end
end
