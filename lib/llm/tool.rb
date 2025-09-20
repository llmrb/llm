# frozen_string_literal: true

##
# The {LLM::Tool LLM::Tool} class represents a local tool
# that can be called by an LLM. Under the hood, it is a wrapper
# around {LLM::Function LLM::Function} but allows the definition
# of a function (also known as a tool) as a class.
# @example
#   class System < LLM::Tool
#     name "system"
#     description "Runs system commands"
#     params do |schema|
#       schema.object(command: schema.string.required)
#     end
#
#     def call(command:)
#       {success: Kernel.system(command)}
#     end
#   end
class LLM::Tool
  ##
  # Registers the tool as a function when inherited
  # @param [Class] klass The subclass
  # @return [void]
  def self.inherited(klass)
    function.register(klass)
  end

  ##
  # Returns (or sets) the tool name
  # @param [String, nil] name The tool name
  # @return [String]
  def self.name(name = nil)
    lock do
      function.tap { _1.name(name) }
    end
  end

  ##
  # Returns (or sets) the tool description
  # @param [String, nil] desc The tool description
  # @return [String]
  def self.description(desc = nil)
    lock do
      function.tap { _1.description(desc) }
    end
  end

  ##
  # Returns (or sets) tool parameters
  # @yieldparam [LLM::Schema] schema The schema object to define parameters
  # @return [LLM::Schema]
  def self.params(&)
    lock do
      function.tap { _1.params(&) }
    end
  end

  ##
  # @api private
  def self.function
    lock do
      @function ||= LLM::Function.new(self)
    end
  end

  ##
  # @api private
  def self.lock(&)
    LLM.lock(:tools, &)
  end
end
