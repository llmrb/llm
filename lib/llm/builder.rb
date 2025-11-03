# frozen_string_literal: true

##
# The {LLM::Builder LLM::Builder} class can build a collection
# of messages that can be sent in a single request.
#
# @example
#   llm = LLM.openai(key: ENV["KEY"])
#   bot = LLM::Bot.new(llm)
#   prompt = bot.build_prompt do
#     it.system "Your task is to assist the user"
#     it.user "Hello. Can you assist me?"
#   end
#   res = bot.chat(prompt)
class LLM::Builder
  ##
  # @param [Proc] b
  #  Evaluator block
  def initialize(&b)
    @buffer = []
    @b = b
  end

  ##
  # @return [void]
  def call
    @b.call(self)
  end

  ##
  # @param [String] content
  #  The message
  # @param [Symbol] role
  #  The role (eg user, system)
  # @return [void]
  def chat(content, role: :user)
    @buffer << LLM::Message.new(role, content)
  end

  ##
  # @param [String] content
  #  The message content
  # @return [void]
  def user(content)
    chat(content, role: :user)
  end

  ##
  # @param [String] content
  #  The message content
  # @return [void]
  def system(content)
    chat(content, role: :system)
  end

  ##
  # @return [Array]
  def to_a
    @buffer.dup
  end
end
