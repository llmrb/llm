# frozen_string_literal: true

class JSON::Schema
  ##
  # The {JSON::Schema::Object JSON::Schema::Object} class represents an
  # object value in a JSON schema. It is a subclass of
  # {JSON::Schema::Leaf JSON::Schema::Leaf} and provides methods that
  # can act as constraints.
  class Object < Leaf
    def initialize(properties)
      @properties = properties
    end

    def to_h
      super.merge!({type: "object", properties:, required:})
    end

    def to_json(options = {})
      to_h.to_json(options)
    end

    private

    attr_reader :properties

    def required
      @properties.filter_map {  _2.required? ? _1 : nil }
    end
  end
end
