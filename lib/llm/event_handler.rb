# frozen_string_literal: true

module LLM
  ##
  # @private
  class EventHandler
    ##
    # @param [#<<] stream Streamable
    # @return [LLM::EventHandler]
    def initialize(parser)
      @parser = parser
    end

    ##
    # "data:" event callback
    # @param [LLM::EventStream::Event] event
    # @return [void]
    def on_data(event)
      return if event.end?
      chunk = JSON.parse(event.value)
      @parser.parse!(chunk)
    rescue JSON::ParserError
    end

    ##
    # Returns a fully constructed response body
    # @return [LLM::Object]
    def body = @parser.body
  end
end
