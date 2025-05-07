# frozen_string_literal: true

class JSON::Schema
  ##
  # The {JSON::Schema::Boolean JSON::Schema::Boolean} class represents a
  # boolean value in a JSON schema. It is a subclass of
  # {JSON::Schema::Leaf JSON::Schema::Leaf}.
  class Boolean < Leaf
    def to_h
      super.merge!({type: "boolean"})
    end
  end
end
