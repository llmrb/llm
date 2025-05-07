# frozen_string_literal: true

module LLM
  class Response::Completion < Response
    ##
    # @return [String]
    #   Returns the model name used for the completion
    def model
      parsed[:model]
    end

    ##
    # @return [Array<LLM::Message>]
    #   Returns an array of messages
    def choices
      parsed[:choices]
    end
    alias_method :messages, :choices

    ##
    # @return [Integer]
    #   Returns the count of prompt tokens
    def prompt_tokens
      parsed[:prompt_tokens]
    end

    ##
    # @return [Integer]
    #   Returns the count of completion tokens
    def completion_tokens
      parsed[:completion_tokens]
    end

    ##
    # @return [Integer]
    #   Returns the total count of tokens
    def total_tokens
      prompt_tokens + completion_tokens
    end

    private

    ##
    # @private
    # @return [Hash]
    #   Returns the parsed completion response from the provider
    def parsed
      @parsed ||= parse_completion(body)
    end
  end
end
