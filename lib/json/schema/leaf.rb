# frozen_string_literal: true

class JSON::Schema
  class Leaf
    def initialize
      @description = nil
      @default = nil
      @enum = nil
      @required = nil
    end

    def description(str)
      tap { @description = str }
    end

    def default(value)
      tap { @default = value }
    end

    def enum(*values)
      tap { @enum = values }
    end

    def required
      tap { @required = true }
    end

    def to_h
      {description: @description, default: @default, enum: @enum}.compact
    end

    def to_json(options = {})
      to_h.to_json(options)
    end

    def required?
      @required
    end
  end
end
