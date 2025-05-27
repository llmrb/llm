# frozen_string_literal: true

module LLM::EventStream
  ##
  # @private
  class Event
    FIELD_REGEXP = /[^:]+/
    VALUE_REGEXP = /(?<=: ).+/

    ##
    # Returns the field name
    # @return [Symbol]
    attr_reader :field

    ##
    # Returns the field value
    # @return [String]
    attr_reader :value

    ##
    # Returns the full chunk
    # @return [String]
    attr_reader :chunk

    ##
    # @param [String] chunk
    # @return [LLM::EventStream::Event]
    def initialize(chunk)
      @field = chunk[FIELD_REGEXP]
      @value = chunk[VALUE_REGEXP]
      @chunk = chunk
    end

    ##
    # Returns true when the event represents an "id" chunk
    # @return [Boolean]
    def id?
      @field == "id"
    end

    ##
    # Returns true when the event represents a "data" chunk
    # @return [Boolean]
    def data?
      @field == "data"
    end

    ##
    # Returns true when the event represents an "event" chunk
    # @return [Boolean]
    def event?
      @field == "event"
    end

    ##
    # Returns true when the event represents a "retry" chunk
    # @return [Boolean]
    def retry?
      @field == "retry"
    end

    ##
    # Returns true when a chunk represents the end of the stream
    # @return [Boolean]
    def end?
      @value == "[DONE]"
    end
  end
end
