# frozen_string_literal: true

class LLM::Function
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
  def call(*)
    @runner.call(*)
  end

  ##
  # @return [Hash]
  def to_h(provider = nil)
    case provider.class.to_s
    when "LLM::Gemini"
      { name: @name, description: @description, parameters: @params }.compact
    else
      {
        type: "function", name: @name,
        function: { name: @name, description: @description, parameters: @params }
      }.compact
    end
  end

  ##
  # @return [String]
  def to_json(options = {})
    to_h(nil).to_json(options)
  end
end
