# frozen_string_literal: true

class LLM::Schema
  ##
  # The {LLM::Schema::Object LLM::Schema::Object} class represents an
  # object value in a JSON schema. It is a subclass of
  # {LLM::Schema::Leaf LLM::Schema::Leaf} and provides methods that
  # can act as constraints.
  class Object < Leaf
    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end

    def to_h
      super.merge!({type: "object", properties:, required:})
    end

    ##
    # @raise [TypeError]
    #  When given an object other than Object
    # @return [LLM::Schema::Object]
    #  Returns self
    def merge!(other)
      raise TypeError unless self.class === self
      @properties.merge!(other.properties)
      self
    end

    def to_json(options = {})
      to_h.to_json(options)
    end

    private

    def required
      @properties.filter_map {  _2.required? ? _1 : nil }
    end
  end
end
