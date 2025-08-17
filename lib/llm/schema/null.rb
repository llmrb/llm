# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::Null LLM::Schema::Null} class represents a
  # null value in a JSON schema. It is a subclass of
  # {LLM::Schema::Leaf LLM::Schema::Leaf}.
  class Null < Leaf
    def to_h
      super.merge!({type: "null"})
    end
  end
end
