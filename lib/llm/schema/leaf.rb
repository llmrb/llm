# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::Leaf LLM::Schema::Leaf} class is the
  # superclass of all values that can appear in a JSON schema.
  # See the instance methods of {LLM::Schema LLM::Schema} for
  # an example of how to create instances of {LLM::Schema::Leaf LLM::Schema::Leaf}
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
    # @return [LLM::Schema::Leaf]
    def description(str)
      tap { @description = str }
    end

    ##
    # Set the default value of a leaf
    # @param [Object] value The default value
    # @return [LLM::Schema::Leaf]
    def default(value)
      tap { @default = value }
    end

    ##
    # Set the allowed values of a leaf
    # @see https://tour.json-schema.org/content/02-Primitive-Types/07-Enumerated-Values-II Enumerated Values
    # @param [Array] values The allowed values
    # @return [LLM::Schema::Leaf]
    def enum(*values)
      tap { @enum = values }
    end

    ##
    # Set the value of a leaf to be a constant value
    # @see https://tour.json-schema.org/content/02-Primitive-Types/08-Defining-Constant-Values Constant Values
    # @param [Object] value The constant value
    # @return [LLM::Schema::Leaf]
    def const(value)
      tap { @const = value }
    end

    ##
    # Denote a leaf as required
    # @return [LLM::Schema::Leaf]
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
