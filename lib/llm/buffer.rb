# frozen_string_literal: true

module LLM
  ##
  # @private
  # {LLM::Buffer LLM::Buffer} provides an Enumerable object that
  # yields each message in a conversation on-demand, and only sends
  # a request to the LLM when a response is needed.
  class Buffer
    include Enumerable

    ##
    # @param [LLM::Provider] provider
    # @return [LLM::Buffer]
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
      empty! unless @pending.empty?
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

    ##
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "completed_count=#{@completed.size} pending_count=#{@pending.size}>"
    end

    private

    def empty!
      message, params, method = @pending[-1]
      if method == :complete
        complete!(message, params)
      elsif method == :respond
        respond!(message, params)
      else
        raise LLM::Error, "Unknown method: #{method}"
      end
    end

    def complete!(message, params)
      messages = @pending[0..-2].map { _1[0] }
      completion = @provider.complete(
        message.content,
        message.role,
        **params.merge(messages:)
      )
      @completed.concat([*messages, message, completion.choices[0]])
      @pending.clear
    end

    def respond!(message, params)
      input = @pending[0..-2].map { _1[0] }
      @response = @provider.responses.create(
        message.content,
        message.role,
        **params.merge(input:).merge(@response ? {previous_response_id: @response.id} : {})
      )
      @completed.concat([*input, message, @response.outputs[0]])
      @pending.clear
    end
  end
end
