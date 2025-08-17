# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::String LLM::Schema::String} class represents a
  # string value in a JSON schema. It is a subclass of
  # {LLM::Schema::Leaf LLM::Schema::Leaf} and provides methods that
  # can act as constraints.
  class String < Leaf
    ##
    # Constrain the string to a minimum length
    # @param [Integer] i The minimum length
    # @return [LLM::Schema::String] Returns self
    def min(i)
      tap { @minimum = i }
    end

    ##
    # Constrain the string to a maximum length
    # @param [Integer] i The maximum length
    # @return [LLM::Schema::String] Returns self
    def max(i)
      tap { @maximum = i }
    end

    def to_h
      super.merge!({
        type: "string",
        minLength: @minimum,
        maxLength: @maximum
      }).compact
    end
  end
end
