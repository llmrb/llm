# frozen_string_literal: true

class JSON::Schema
  ##
  # The {JSON::Schema::Leaf JSON::Schema::Leaf} class is the
  # superclass of all values that can appear in a JSON schema.
  # See the instance methods of {JSON::Schema JSON::Schema} for
  # an example of how to create instances of {JSON::Schema::Leaf JSON::Schema::Leaf}
  # through its subclasses.
  class Leaf
    def initialize
      @description = nil
      @default = nil
      @enum = nil
      @required = nil
      @const = nil
    end

    ##
    # Set the description of a leaf
    # @param [String] str The description
    # @return [JSON::Schema::Leaf]
    def description(str)
      tap { @description = str }
    end

    ##
    # Set the default value of a leaf
    # @param [Object] value The default value
    # @return [JSON::Schema::Leaf]
    def default(value)
      tap { @default = value }
    end

    ##
    # Set the allowed values of a leaf
    # @see https://tour.json-schema.org/content/02-Primitive-Types/07-Enumerated-Values-II Enumerated Values
    # @param [Array] values The allowed values
    # @return [JSON::Schema::Leaf]
    def enum(*values)
      tap { @enum = values }
    end

    ##
    # Set the value of a leaf to be a constant value
    # @see https://tour.json-schema.org/content/02-Primitive-Types/08-Defining-Constant-Values Constant Values
    # @param [Object] value The constant value
    # @return [JSON::Schema::Leaf]
    def const(value)
      tap { @const = value }
    end

    ##
    # Denote a leaf as required
    # @return [JSON::Schema::Leaf]
    def required
      tap { @required = true }
    end

    ##
    # @return [Hash]
    def to_h
      {description: @description, default: @default, enum: @enum}.compact
    end

    ##
    # @return [String]
    def to_json(options = {})
      to_h.to_json(options)
    end

    ##
    # @return [Boolean]
    def required?
      @required
    end
  end
end
