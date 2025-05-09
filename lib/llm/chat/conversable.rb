# frozen_string_literal: true

class LLM::Chat
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
    # Sends a response to the provider and returns the response.
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [LLM::Response::Respond]
    def sync_response(prompt, params = {})
      role = params[:role]
      @response = create_response!(prompt, params)
      @messages.concat [Message.new(role, prompt), @response.outputs[0]]
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

    ##
    # Sends a completion to the provider and returns the completion.
    # @param [String] prompt The prompt
    # @param [Hash] params
    # @return [LLM::Response::Completion]
    def sync_completion(prompt, params = {})
      role = params[:role]
      completion = create_completion!(prompt, params)
      @messages.concat [Message.new(role, prompt), completion.choices[0]]
    end

    include LLM
  end
end
