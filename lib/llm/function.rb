# frozen_string_literal: true

##
# The {LLM::Function LLM::Function} class represents a local
# function that can be called by an LLM.
#
# @example example #1
#   LLM.function(:system) do |fn|
#     fn.description "Runs system commands"
#     fn.params do |schema|
#       schema.object(command: schema.string.required)
#     end
#     fn.define do |command:|
#       {success: Kernel.system(command)}
#     end
#   end
#
# @example example #2
#   class System
#     def call(command:)
#       {success: Kernel.system(command)}
#     end
#   end
#
#   LLM.function(:system) do |fn|
#     fn.description "Runs system commands"
#     fn.params do |schema|
#       schema.object(command: schema.string.required)
#     end
#     fn.register(System)
#   end
class LLM::Function
  class Return < Struct.new(:id, :value)
  end

  ##
  # Returns the function ID
  # @return [String, nil]
  attr_accessor :id

  ##
  # Returns the function name
  # @return [String]
  attr_reader :name

  ##
  # Returns function arguments
  # @return [Array, nil]
  attr_accessor :arguments

  ##
  # @param [String] name The function name
  # @yieldparam [LLM::Function] self The function object
  def initialize(name, &b)
    @name = name
    @schema = JSON::Schema.new
    @called = false
    @cancelled = false
    yield(self)
  end

  ##
  # Set the function description
  # @param [String] desc The function description
  # @return [void]
  def description(desc = nil)
    if desc
      @description = desc
    else
      @description
    end
  end

  ##
  # @yieldparam [JSON::Schema] schema The schema object
  # @return [void]
  def params
    @params = yield(@schema)
  end

  ##
  # Set the function implementation
  # @param [Proc, Class] b The function implementation
  # @return [void]
  def define(klass = nil, &b)
    @runner = klass || b
  end
  alias_method :register, :define

  ##
  # Call the function
  # @return [LLM::Function::Return] The result of the function call
  def call
    runner = ((Class === @runner) ? @runner.new : @runner)
    Return.new(id, runner.call(**arguments))
  ensure
    @called = true
  end

  ##
  # Returns a value that communicates that the function call was cancelled
  # @example
  #   llm = LLM.openai(key: ENV["KEY"])
  #   bot = LLM::Bot.new(llm, tools: [fn1, fn2])
  #   bot.chat "I want to run the functions"
  #   bot.chat bot.functions.map(&:cancel)
  # @return [LLM::Function::Return]
  def cancel(reason: "function call cancelled")
    Return.new(id, {cancelled: true, reason:})
  ensure
    @cancelled = true
  end

  ##
  # Returns true when a function has been called
  # @return [Boolean]
  def called?
    @called
  end

  ##
  # Returns true when a function has been cancelled
  # @return [Boolean]
  def cancelled?
    @cancelled
  end

  ##
  # Returns true when a function has neither been called nor cancelled
  # @return [Boolean]
  def pending?
    !@called && !@cancelled
  end

  ##
  # @return [Hash]
  def format(provider)
    case provider.class.to_s
    when "LLM::Gemini"
      {name: @name, description: @description, parameters: @params}.compact
    when "LLM::Anthropic"
      {name: @name, description: @description, input_schema: @params}.compact
    else
      {
        type: "function", name: @name,
        function: {name: @name, description: @description, parameters: @params}
      }.compact
    end
  end
end
