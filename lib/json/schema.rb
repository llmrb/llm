# frozen_string_literal: true

module JSON
end unless defined?(JSON)

class JSON::Schema
  require_relative "schema/leaf"
  require_relative "schema/object"
  require_relative "schema/array"
  require_relative "schema/string"
  require_relative "schema/number"
  require_relative "schema/integer"
  require_relative "schema/boolean"
  require_relative "schema/null"

  ##
  # Returns an object
  # @param properties [Hash] A hash of properties
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Object]
  def object(properties, **rest)
    Object.new(properties, **rest)
  end

  ##
  # Returns an array
  # @param items [Array] An array of items
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Array]
  def array(items, **rest)
    Array.new(items, **rest)
  end

  ##
  # Returns a string
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::String]
  def string(...)
    String.new(...)
  end

  ##
  # Returns a number
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Number] a number
  def number(...)
    Number.new(...)
  end

  ##
  # Returns an integer
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Integer]
  def integer(...)
    Integer.new(...)
  end

  ##
  # Returns a boolean
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Boolean]
  def boolean(...)
    Boolean.new(...)
  end

  ##
  # Returns null
  # @param rest [Hash] Any other options
  # @return [JSON::Schema::Null]
  def null(...)
    Null.new(...)
  end
end
