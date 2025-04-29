# frozen_string_literal: true

class JSON::Schema
  class Booelean < Leaf
    def to_h
      super.merge!({type: "boolean"})
    end
  end
end
