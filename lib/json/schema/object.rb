# frozen_string_literal: true

class JSON::Schema
  class Object < Leaf
    def initialize(properties, **rest)
      @properties = properties
      super(**rest)
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
