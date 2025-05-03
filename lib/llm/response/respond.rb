# frozen_string_literal: true

module LLM
  class Response::Respond < Response
    ##
    # @return [String]
    #  Returns the id of the response
    def id
      parsed[:id]
    end

    ##
    # @return [String]
    #  Returns the model name
    def model
      parsed[:model]
    end

    ##
    # @return [Array<LLM::Message>]
    def outputs
      parsed[:outputs]
    end

    ##
    # @return [Integer]
    #  Returns the input token count
    def input_tokens
      parsed[:input_tokens]
    end

    ##
    # @return [Integer]
    #  Returns the output token count
    def output_tokens
      parsed[:output_tokens]
    end

    ##
    # @return [Integer]
    #  Returns the total count of tokens
    def total_tokens
      parsed[:total_tokens]
    end

    private

    ##
    # @private
    # @return [Hash]
    #  Returns the parsed response from the provider
    def parsed
      @parsed ||= parse_output_response(body)
    end
  end
end
