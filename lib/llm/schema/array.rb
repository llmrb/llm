# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::Array LLM::Schema::Array} class represents an
  # array value in a JSON schema. It is a subclass of
  # {LLM::Schema::Leaf LLM::Schema::Leaf} and provides methods that
  # can act as constraints.
  class Array < Leaf
    def initialize(items)
      @items = items
    end

    def to_h
      super.merge!({type: "array", items:})
    end

    def to_json(options = {})
      to_h.to_json(options)
    end

    private

    attr_reader :items
  end
end
