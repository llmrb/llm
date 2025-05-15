# frozen_string_literal: true

require_relative "openai" unless defined?(LLM::OpenAI)

module LLM
  ##
  # The DeepSeek class implements a provider for
  # [DeepSeek](https://deepseek.com)
  # through its OpenAI-compatible API provided via
  # their [web platform](https://platform.deepseek.com).
  class DeepSeek < OpenAI
    require_relative "deepseek/format"
    include DeepSeek::Format

    ##
    # @param (see LLM::Provider#initialize)
    # @return [LLM::DeepSeek]
    def initialize(host: "api.deepseek.com", port: 443, ssl: true, **)
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
    # @raise [NotImplementedError]
    def moderations
      raise NotImplementedError
    end

    ##
    # @raise [NotImplementedError]
    def responses
      raise NotImplementedError
    end

    ##
    # Returns the default model for chat completions
    # @see https://api-docs.deepseek.com/quick_start/pricing deepseek-chat
    # @return [String]
    def default_model
      "deepseek-chat"
    end
  end
end
