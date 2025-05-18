# frozen_string_literal: true

module LLM::Chat::Prompt
  class Completion < Struct.new(:bot, :defaults)
    ##
    # @param [LLM::Chat] bot
    # @param [Hash] defaults
    # @return [LLM::Chat::Prompt::Completion]
    def initialize(bot, defaults)
      super(bot, defaults || {})
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def system(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :system)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Chat]
    def user(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :user)
    end
  end
end
