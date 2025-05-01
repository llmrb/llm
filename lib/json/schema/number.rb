# frozen_string_literal: true

class JSON::Schema
  ##
  # The {JSON::Schema::Number JSON::Schema::Number} class represents a
  # a number (either whole or decimal) value in a JSON schema. It is a
  # subclass of {JSON::Schema::Leaf JSON::Schema::Leaf} and provides
  # methods that can act as constraints.
  class Number < Leaf
    ##
    # Constrain the number to a minimum value
    # @param [Integer, Float] i The minimum value
    # @return [JSON::Schema::Number] Returns self
    def min(i)
      tap { @minimum = i }
    end

    ##
    # Constrain the number to a maximum value
    # @param [Integer, Float] i The maximum value
    # @return [JSON::Schema::Number] Returns self
    def max(i)
      tap { @maximum = i }
    end

    ##
    # Constrain the number to a multiple of a given value
    # @param [Integer, Float] i The multiple
    # @return [JSON::Schema::Number] Returns self
    def multiple_of(i)
      tap { @multiple_of = i }
    end

    def to_h
      super.merge!({
        type: "number",
        minimum: @minimum,
        maximum: @maximum,
        multipleOf: @multiple_of
      }).compact
    end
  end
end
