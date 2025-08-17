# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::Boolean LLM::Schema::Boolean} class represents a
  # boolean value in a JSON schema. It is a subclass of
  # {LLM::Schema::Leaf LLM::Schema::Leaf}.
  class Boolean < Leaf
    def to_h
      super.merge!({type: "boolean"})
    end
  end
end
