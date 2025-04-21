# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::File LLM::Response::File} class represents a file
  # that has been uploaded to a provider. Its properties are delegated
  # to the underlying response body, and vary by provider.
  class Response::File < Response
    private

    include LLM::Utils

    def respond_to_missing?(m, _)
      body.key?(m.to_s) || body.key?(camelcase(m)) || super
    end

    def method_missing(m, *args, &block)
      if body.key?(m.to_s)
        body[m.to_s]
      elsif body.key?(camelcase(m))
        body[camelcase(m)]
      else
        super
      end
    end

    def body
      super["file"] || super
    end
  end
end
