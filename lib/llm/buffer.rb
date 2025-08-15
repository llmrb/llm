# frozen_string_literal: true

module LLM
  ##
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
    def each(...)
      if block_given?
        empty! unless @pending.empty?
        @completed.each { yield(_1) }
      else
        enum_for(:each, ...)
      end
    end

    ##
    # Returns an array of unread messages
    # @see LLM::Message#read?
    # @see LLM::Message#read!
    # @return [Array<LLM::Message>]
    def unread
      reject(&:read?)
    end

    ##
    # Find a message (in descending order)
    # @return [LLM::Message, nil]
    def find(...)
      reverse_each.find(...)
    end

    ##
    # Returns the last message in the buffer
    # @return [LLM::Message, nil]
    def last
      to_a[-1]
    end

    ##
    # @param [[LLM::Message, Hash, Symbol]] item
    #  A message and its parameters
    # @return [void]
    def <<(item)
      @pending << item
      self
    end
    alias_method :push, :<<

    ##
    # @param [Integer, #to_i] index
    #  The message index
    # @return [LLM::Message, nil]
    #  Returns a message, or nil
    def [](index)
      @completed[index.to_i] || to_a[index.to_i]
    end

    ##
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " \
      "completed_count=#{@completed.size} pending_count=#{@pending.size}>"
    end

    ##
    # Returns true when the buffer is empty
    # @return [Boolean]
    def empty?
      @pending.empty? and @completed.empty?
    end

    private

    def empty!
      message, params, method = @pending.pop
      if method == :complete
        complete!(message, params)
      elsif method == :respond
        respond!(message, params)
      else
        raise LLM::Error, "Unknown method: #{method}"
      end
    end

    def complete!(message, params)
      pendings = @pending.map { _1[0] }
      messages = [*@completed, *pendings]
      role = message.role
      completion = @provider.complete(
        message.content,
        params.merge(role:, messages:)
      )
      @completed.concat([*pendings, message, *completion.choices[0]])
      @pending.clear
    end

    def respond!(message, params)
      pendings = @pending.map { _1[0] }
      input = [*pendings]
      role = message.role
      params = [
        params.merge(input:),
        @response ? {previous_response_id: @response.id} : {}
      ].inject({}, &:merge!)
      @response = @provider.responses.create(message.content, params.merge(role:))
      @completed.concat([*pendings, message, *@response.outputs[0]])
      @pending.clear
    end
  end
end
