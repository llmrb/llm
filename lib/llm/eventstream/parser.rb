# frozen_string_literal: true

module LLM::EventStream
  ##
  # @private
  class Parser
    ##
    # @return [LLM::EventStream::Parser]
    def initialize
      @buffer = StringIO.new
      @events = Hash.new { |h, k| h[k] = [] }
    end

    ##
    # Register a visitor
    # @param [#on_data] visitor
    # @return [void]
    def register(visitor)
      @visitor = visitor
    end

    ##
    # Subscribe to an event
    # @param [Symbol] event
    # @param [Proc] block
    # @return [void]
    def on(evtname, &block)
      @events[evtname.to_s] << block
    end

    ##
    # Append an event to the internal buffer
    # @return [void]
    def <<(event)
      io = StringIO.new(event)
      IO.copy_stream io, @buffer
      @buffer.string.each_line { parse!(_1) }
    end

    ##
    # Returns the internal buffer
    # @return [String]
    def body
      @buffer.string
    end

    ##
    # Free the internal buffer
    # @return [void]
    def free
      @buffer.truncate(0)
      @buffer.rewind
    end

    private

    def parse!(event)
      event = Event.new(event)
      dispatch(event)
    end

    def dispatch(event)
      if @visitor
        dispatch_visitor(event)
      else
        @events[event.field].each { _1.call(event) }
      end
    end

    def dispatch_visitor(event)
      method = "on_#{event.field}"
      if @visitor.respond_to?(method)
        @visitor.public_send(method, event)
      end
    end
  end
end
