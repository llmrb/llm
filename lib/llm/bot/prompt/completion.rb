# frozen_string_literal: true

module LLM::Bot::Prompt
  class Completion < Struct.new(:bot, :defaults)
    ##
    # @param [LLM::Bot] bot
    # @param [Hash] defaults
    # @return [LLM::Bot::Prompt::Completion]
    def initialize(bot, defaults)
      super(bot, defaults || {})
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Bot]
    def system(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :system)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Bot]
    def user(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :user)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Bot]
    def assistant(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :assistant)
    end

    ##
    # @param [String] prompt
    # @param [Hash] params (see LLM::Provider#complete)
    # @return [LLM::Bot]
    def model(prompt, params = {})
      params = defaults.merge(params)
      bot.chat prompt, params.merge(role: :model)
    end
  end
end
