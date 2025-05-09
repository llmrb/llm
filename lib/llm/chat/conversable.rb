# frozen_string_literal: true

class LLM::Chat
  ##
  # @private
  module Conversable
    private

    def async_response(prompt, params = {})
      role = params.delete(:role)
      @messages << [LLM::Message.new(role, prompt), @params.merge(params), :respond]
    end

    def sync_response(prompt, params = {})
      role = params[:role]
      @response = create_response!(prompt, params)
      @messages.concat [Message.new(role, prompt), @response.outputs[0]]
    end

    def async_completion(prompt, params = {})
      role = params.delete(:role)
      @messages.push [LLM::Message.new(role, prompt), @params.merge(params), :complete]
    end

    def sync_completion(prompt, params = {})
      role = params[:role]
      completion = create_completion!(prompt, params)
      @messages.concat [Message.new(role, prompt), completion.choices[0]]
    end

    include LLM
  end
end
