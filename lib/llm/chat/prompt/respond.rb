# frozen_string_literal: true

module LLM::Chat::Prompt
  class Respond < Struct.new(:bot)
    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def system(prompt, params = {})
      bot.respond prompt, params.merge(role: :system)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def developer(prompt, params = {})
      bot.respond prompt, params.merge(role: :developer)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def user(prompt, params = {})
      bot.respond prompt, params.merge(role: :user)
    end
  end
end
