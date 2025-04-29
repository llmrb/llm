# frozen_string_literal: true

class JSON::Schema
  class Null < Leaf
    def to_h
      super.merge!({type: "null"})
    end
  end
end
