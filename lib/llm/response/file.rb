# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::File LLM::Response::File} class represents a file
  # that has been uploaded to a provider. Its properties are delegated
  # to the underlying response body, and vary by provider.
  class Response::File < Response
    ##
    # Returns a normalized response body
    # @return [Hash]
    def body
      @_body ||= if super["file"]
        super["file"].transform_keys { snakecase(_1) }
      else
        super.transform_keys { snakecase(_1) }
      end
    end

    ##
    # @return [String]
    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} body=#{body}>"
    end

    private

    include LLM::Utils

    def respond_to_missing?(m, _)
      body.key?(m.to_s) || super
    end

    def method_missing(m, *args, &block)
      if body.key?(m.to_s)
        body[m.to_s]
      else
        super
      end
    end
  end
end
