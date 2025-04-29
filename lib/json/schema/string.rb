# frozen_string_literal: true

class JSON::Schema
  class String < Leaf
    def to_h
      super.merge!({type: "string"})
    end
  end
end
