# frozen_string_literal: true

class LLM::Chat
  ##
  # @private
  module Builder
    private

    def create_response!(prompt, params)
      @provider.responses.create(
        prompt,
        @params.merge(params.merge(@response ? {previous_response_id: @response.id} : {}))
      )
    end

    def create_completion!(prompt, params)
      @provider.complete(
        prompt,
        @params.merge(params.merge(messages:))
      )
    end
  end
end
