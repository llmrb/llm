# frozen_string_literal: true

module LLM
  ##
  # The LlamaCpp class implements a provider for
  # [llama.cpp](https://github.com/ggml-org/llama.cpp)
  # through the OpenAI-compatible API provided by the
  # llama-server binary.
  class LlamaCpp < OpenAI
    ##
    # @param (see LLM::Provider#initialize)
    # @return [LLM::LlamaCpp]
    def initialize(host: "localhost", port: 8080, ssl: false, **)
      super
    end

    ##
    # @raise [NotImplementedError]
    def files
      raise NotImplementedError
    end

    ##
    # @raise [NotImplementedError]
    def images
      raise NotImplementedError
    end

    ##
    # @raise [NotImplementedError]
    def audio
      raise NotImplementedError
    end

    ##
    # Returns the default model for chat completions
    # @see https://ollama.com/library llama3.2
    # @return [String]
    def default_model
      "llama3.2"
    end
  end
end
