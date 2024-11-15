module LLM
  class LazyThread
    include Enumerable

    ##
    # @param [LLM::Provider] provider
    # @return [LLM::LazyThread]
    def initialize(provider)
      @provider = provider
      @thread = []
    end

    ##
    # @yield [LLM::Message]
    #  Yields each message in the conversation thread
    # @raise (see LLM::Provider#complete)
    # @return [void]
    def each
      @thread = complete! unless @thread.grep(LLM::Message).size == @thread.size
      @thread.each { yield(_1) }
    end

    ##
    # @param message [Object]
    #  A message to add to the conversation thread
    # @return [void]
    def <<(message)
      @thread << message
    end
    alias_method :push, :<<

    private

    def complete!
      prompt, role, params = @thread[-1]
      rest = @thread[0..-2].map { (Array === _1) ? LLM::Message.new(_1[1], _1[0]) : _1 }
      comp = @provider.complete(prompt, role, **params.merge(messages: rest)).choices.last
      [*rest, LLM::Message.new(role, prompt), comp]
    end
  end
end
