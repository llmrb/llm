# frozen_string_literal: true

##
# The {LLM::Function LLM::Function} class represents a function that can
# be called by an LLM. It comes in two forms: a Proc-based function,
# or a Class-based function.
#
# @example
#   # Proc-based
#   LLM.function(:system) do |fn|
#     fn.description "Runs system commands, emits their output"
#     fn.params do |schema|
#       schema.object(command: schema.string.required)
#     end
#     fn.define do |params|
#       Kernel.system(params.command)
#     end
#   end
#
# @example
#   # Class-based
#   class System
#     def call(params)
#       Kernel.system(params.command)
#     end
#   end
#
#   LLM.function(:system) do |fn|
#     fn.description "Runs system commands, emits their output"
#     fn.params do |schema|
#       schema.object(command: schema.string.required)
#     end
#     fn.register(System)
#   end
class LLM::Function
  class Return < Struct.new(:id, :value)
  end

  ##
  # Returns the function name
  # @return [String]
  attr_reader :name

  ##
  # Returns function arguments
  # @return [Array, nil]
  attr_accessor :arguments

  ##
  # Returns the function ID
  # @return [String, nil]
  attr_accessor :id

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
  # @param [String] str The function description
  # @return [void]
  def description(str)
    @description = str
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
    Return.new id, (Class === @runner) ? @runner.new.call(arguments) : @runner.call(arguments)
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
