# frozen_string_literal: true

class LLM::Bot
  ##
  # @private
  module Conversable
    private

    ##
    # Queues a response to be sent to the provider.
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [void]
    def async_response(prompt, params = {})
      role = params.delete(:role)
      @messages << [LLM::Message.new(role, prompt), @params.merge(params), :respond]
    end

    ##
    # Queues a completion to be sent to the provider.
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [void]
    def async_completion(prompt, params = {})
      role = params.delete(:role)
      @messages.push [LLM::Message.new(role, prompt), @params.merge(params), :complete]
    end

    include LLM
  end
end
