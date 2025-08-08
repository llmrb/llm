# frozen_string_literal: true

class LLM::Bot
  ##
  # @private
  module Builder
    private

    ##
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [LLM::Response]
    def create_response!(prompt, params)
      @provider.responses.create(
        prompt,
        @params.merge(params.merge(@response ? {previous_response_id: @response.id} : {}))
      )
    end

    ##
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [LLM::Response]
    def create_completion!(prompt, params)
      @provider.complete(
        prompt,
        @params.merge(params.merge(messages:))
      )
    end
  end
end
