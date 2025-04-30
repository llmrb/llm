# frozen_string_literal: true

class JSON::Schema
  class Array < Leaf
    def initialize(*items)
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
