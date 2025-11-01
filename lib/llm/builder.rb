  # frozen_string_literal: true

  ##
  # The {LLM::Builder LLM::Builder} class can build a collection
  # of messages that can be sent in a single request.
  #
  # @example
  #   llm = LLM.openai(key: ENV["KEY"])
  #   bot = LLM::Bot.new(llm)
  #   req = llm.build do |prompt|
  #     prompt.chat "Your task is to asset the user", role: :system
  #     prompt.chat "Hello. Can you assist me?", role: :user
  #   end
  #   res = bot.chat(req)
  class LLM::Builder
    def initialize(&b)
      @buffer = []
      @b = &b
    end

    def call
      @b.call(self)
    end

    def chat(content, role:)
      @buffer << LLM::Message.new(role, content)
    end

    def to_a
      @buffer
    end
  end