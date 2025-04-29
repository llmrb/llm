# frozen_string_literal: true

class JSON::Schema
  class Integer < Leaf
    def min(i)
      tap { @minimum = i }
    end

    def max(i)
      tap { @maximum = i }
    end

    def to_h
      super.merge!({
        type: "integer",
        minimum: @minimum,
        maximum: @maximum
      }).compact
    end
  end
end
