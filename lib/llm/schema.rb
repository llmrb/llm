# frozen_string_literal: true

##
# The {LLM::Schema LLM::Schema} class represents a JSON schema,
# and provides methods that let you describe and produce a schema
# that can be used in various contexts that include the validation
# and generation of JSON data.
#
# @see https://json-schema.org/ JSON Schema Specification
# @see https://tour.json-schema.org/ JSON Schema Tour
#
# @example
#  schema = LLM::Schema.new
#  schema.object({
#    name: schema.string.enum("John", "Jane").required,
#    age: schema.integer.required,
#    hobbies: schema.array(schema.string, schema.null).required,
#    address: schema.object({street: schema.string}).required,
#  })
class LLM::Schema
  require_relative "schema/version"
  require_relative "schema/leaf"
  require_relative "schema/object"
  require_relative "schema/array"
  require_relative "schema/string"
  require_relative "schema/number"
  require_relative "schema/integer"
  require_relative "schema/boolean"
  require_relative "schema/null"

  ##
  # Configures a monitor for a subclass
  # @return [void]
  def self.inherited(klass)
    LLM.lock(:inherited) do
      klass.instance_eval { @__monitor = Monitor.new }
    end
  end

  ##
  # @param [String] name
  #  The property name
  # @param [Class] type
  #  The property type
  # @param [String] description
  #  The property description
  # @param [Hash] options
  #  A hash of options
  def self.property(name, type, description, options = {})
    lock do
      if LLM::Schema::Leaf === type
        prop = type
      else
        target = type.name.split("::").last.downcase
        prop = schema.public_send(target)
      end
      options = {description:}.merge(options)
      options.each { (_2 == true) ? prop.public_send(_1) : prop.public_send(_1, _2) }
      object[name] = prop
    end
  end

  ##
  # @api private
  # @return [LLM::Schema]
  def self.schema
    lock do
      @schema ||= LLM::Schema.new
    end
  end

  ##
  # @api private
  # @return [LLM::Schema::Object]
  def self.object
    lock do
      @object ||= schema.object({})
    end
  end

  ##
  # @api private
  def self.lock(&)
    @__monitor.synchronize(&)
  end
  private_class_method :lock

  ##
  # Returns an object
  # @param [Hash] properties A hash of properties
  # @return [LLM::Schema::Object]
  def object(properties)
    Object.new(properties)
  end

  ##
  # Returns an array
  # @param [Array] items An array of items
  # @return [LLM::Schema::Array]
  def array(*items)
    Array.new(*items)
  end

  ##
  # Returns a string
  # @return [LLM::Schema::String]
  def string
    String.new
  end

  ##
  # Returns a number
  # @return [LLM::Schema::Number] a number
  def number
    Number.new
  end

  ##
  # Returns an integer
  # @return [LLM::Schema::Integer]
  def integer
    Integer.new
  end

  ##
  # Returns a boolean
  # @return [LLM::Schema::Boolean]
  def boolean
    Boolean.new
  end

  ##
  # Returns null
  # @return [LLM::Schema::Null]
  def null
    Null.new
  end
end
