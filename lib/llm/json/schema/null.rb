# frozen_string_literal: true

class JSON::Schema
  ##
  # The {JSON::Schema::Null JSON::Schema::Null} class represents a
  # null value in a JSON schema. It is a subclass of
  # {JSON::Schema::Leaf JSON::Schema::Leaf}.
  class Null < Leaf
    def to_h
      super.merge!({type: "null"})
    end
  end
end
