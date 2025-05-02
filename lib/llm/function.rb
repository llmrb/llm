# frozen_string_literal: true

class LLM::Function
  ##
  # Returns function arguments
  # @return [Array]
  attr_accessor :arguments

  ##
  # @param [String] name The function name
  # @yieldparam [LLM::Function] self The function object
  def initialize(name, &b)
    @name = name
    @schema = JSON::Schema.new
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
  # @param [Proc] b The function implementation
  # @return [void]
  def define(&b)
    @runner = b
  end

  ##
  # Call the function
  # @param [Array] args The arguments to pass to the function
  # @return [Object] The result of the function call
  def call
    @runner.call(arguments)
  ensure
    @called = true
  end

  ##
  # Returns true when a function has been called
  # @return [Boolean]
  def called?
    @called
  end

  ##
  # @return [Hash]
  def format(provider)
    case provider.class.to_s
    when "LLM::Gemini"
      {name: @name, description: @description, parameters: @params}.compact
    else
      {
        type: "function", name: @name,
        function: {name: @name, description: @description, parameters: @params}
      }.compact
    end
  end
end
